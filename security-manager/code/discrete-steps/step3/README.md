- implement SecuredContract class
- modify Contract1 and Contract2 to inherit SecuredContract
- replace 'require' with a modifier 

Now that we have two contracts, we see that there is some redundant code. For one thing, that 'require' in each of the restricted could be replaced by a more readable modifier. One way to do this is by creating a common class to hold the common code and making Contract1 and Contract2 subclasses. You can also use a library module or some other method if you prefer; the point here is just to tidy up and avoid repeating ourselves in code.