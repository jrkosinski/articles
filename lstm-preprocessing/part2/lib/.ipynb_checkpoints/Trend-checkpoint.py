import pandas as pd 
import numpy as np

# -----------------------------------------------------------------
# Encapsulates a single data point indicating a trend change. 
# 
class TrendPoint: 
    def __init__(self, index: int, price: float, point_type: str): 
        self.index = index
        self.price = price
        self.point_type = point_type
    
# -----------------------------------------------------------------
# Encapsulates a metaseries indicating trend changes in a price 
# series. 
# 
class TrendData: 
    def __init__(self): 
        self.points = list()
        
    @property
    def length(self): 
        return len(self.points)
    
    @property 
    def last_point(self): 
        if (self.length) < 1: 
            return None
        return self.points[-1]

    # -----------------------------------------------------------------
    # Appends a data point of a given type to the end of the metaseries.
    # If a point of that type already exists at the end of the metaseries, 
    # it is replaced with the new point's data.
    # 
    def append_point(self, index: int, price: float, ptype: str): 
        if (self.length > 0 and self.points[-1].point_type == ptype): 
            self.points[-1].index = index
            self.points[-1].price = price
        else:
            self.points.append(TrendPoint(index, price, ptype))
    
    # -----------------------------------------------------------------
    # Returns the metaseries normalized to be overlaid over the original
    # price series.
    # 
    def as_price_series(self, start_price: float): 
        series = list()
        index = 0
        price = start_price
        
        for i in range(self.length): 
            point = self.points[i]
            price_diff = point.price - price
            index_diff = point.index - index
            if (index_diff > 1): 
                slope = price_diff / index_diff
                
                for n in range(index_diff): 
                    series.append(price + (n * slope))
                    
                price = point.price
                index = point.index
        
        return series
    
    # -----------------------------------------------------------------
    # Returns the metaseries normalized to the length of the original 
    # price series, with the following form: 
    #
    # trend downturn (reversal to the down direction): 0 
    # trend upturn (reversal to the up direction): 1
    # continuation: 0.5
    # 
    def as_boolean(self, start_price: float): 
        series = list()
        prev_index = 0
        prev_price = start_price
        nn = 0
        
        for i in range(self.length): 
            point = self.points[i]
            price_diff = point.price - prev_price
            index_diff = point.index - prev_index
                
            if (index_diff > 1): 
                for n in range(1, index_diff): 
                    series.append(0.5)
                    #print(nn, ': 0.5')
                    nn+= 1
                    
            if (price_diff < 0): 
                #print(nn, ': 1')
                series.append(1)
                nn+= 1
            else: 
                #print(nn, ': 0')
                series.append(0)
                nn+= 1
                    
            prev_price = point.price
            prev_index = point.index
        
        return series
    
    # -----------------------------------------------------------------
    # Returns an x,y series containing either the highs (trend downturns)
    # or the lows (trend upturns). 
    #
    # Returns as tuple: x, y
    # 
    def as_scatterplot(self, ptype: str):
        x = list()
        y = list()
        
        for i in range(self.length): 
            if (self.points[i].point_type == ptype): 
                y.append(self.points[i].price)
                x.append(self.points[i].index)
        
        return x, y
    
    
# -----------------------------------------------------------------
# Extracts an approximation of the trend and trend changes over 
# time of the given price series. 
# 
# df: pandas DataFrame containing the price series column
# col_name: the name of the price column in the given DataFrame
# period: a lower value will result in more granular trend changes 
# 
def extract_trend(series: pd.Series, period: int): 
    values = series.values
    data = TrendData()
    last_hi_price = values[0]
    last_lo_price = values[0]
    
    #get the first high and low of the range 0-period
    first_hi = values[0]
    first_hi_index = 0
    first_lo = values[0]
    first_lo_index = 0
    for i in range(period): 
        if (values[i] > first_hi): 
            first_hi = values[i]
            first_hi_index = i
        if (values[i] < first_lo): 
            first_lo = values[i]
            first_lo_index = i
    
    #append the first high & low in the right order
    if (first_hi_index > first_lo_index): 
        data.append_point(first_lo_index, first_lo, 'lo')
        data.append_point(first_hi_index, first_hi, 'hi')
    else: 
        data.append_point(first_hi_index, first_hi, 'hi')
        data.append_point(first_lo_index, first_lo, 'lo')
        
    #get the remaining trend points
    start_index = period
    end_index = 0
    
    while (start_index < len(values)-1): 
        last_point = data.last_point
    
        # count [period] points out from start
        end_index = start_index + period
        if (end_index > len(values)): 
            end_index = len(values)
            
        new_lo = start_index
        new_hi = start_index
        point_added = False
        
        # find highs & lows in the current series subset 
        for i in range(start_index, end_index): 
            val = values[i]
            if (last_point.point_type == 'hi'): 
                if (val > last_point.price):
                    data.append_point(i, val, 'hi')
                    point_added = True
                    break
                if (val < values[new_lo]): 
                    new_lo = i
            else:
                if (val < last_point.price):
                    data.append_point(i, val, 'lo')
                    point_added = True
                    break
                if (val > values[new_hi]): 
                    new_hi = i
        
        if not point_added: 
            if (values[new_lo] < values[start_index]):
                data.append_point(new_lo, values[new_lo], 'lo')

            if (values[new_hi] > values[start_index]):
                data.append_point(new_hi, values[new_hi], 'hi')
        
        start_index = data.last_point.index
        
    #prepend hi or lo to 0th index
    if (data.points[0].index != 0): 
        data.points.insert(
            0, 
            TrendPoint(
                0, values[0], 'hi' if data.points[0].point_type == 'lo' else 'hi'
            )
        )
    return data