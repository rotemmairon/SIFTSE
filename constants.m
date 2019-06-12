function res = constants(label)

switch (label)
    
    case 'pathlen'
        res = 20;
    
    case 'nregions'
        res = 300;
        
    case 'nstates'
        res = 7;
    
    case 'nwords'
        res = 10;
        
    case 'tol'
        res = 1e-4;
        
    case 'imax'
        res = 50;
        
end