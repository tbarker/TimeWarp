TimeWarp
=========

A simple package for winding back (and forward) the Oracle system clock for testing.  Very useful when combined with [plunit](http://plunit.com/).


Usage
------

    SQL> EXEC timewarp.jump( '12-APR-1971' );
    
    PL/SQL procedure successfully completed.
    
    
    SQL> select sysdate from dual;

    SYSDATE
    ---------
    12-APR-71
    
    SQL> EXEC timewarp.fwd( -3 );
    
    PL/SQL procedure successfully completed.
    
    SQL> select sysdate from dual;
    
    SYSDATE
    ---------
    09-APR-71
    
    SQL> EXEC timewarp.reset;
    
    PL/SQL procedure successfully completed.
    
    SQL> select sysdate from dual;
    
    SYSDATE
    ---------
    23-JAN-11
    
    SQL> EXEC timewarp.fastfwd( sysdate - 3, sysdate + 1, 'BEGIN dbms_output.put_line( sysdate ); END;', 0.7 );
    [FAST FWD] Starting at 20-JAN-11
    20-JAN-11
    21-JAN-11
    21-JAN-11
    22-JAN-11
    23-JAN-11
    23-JAN-11
    [FAST FWD] Ending with 24-JAN-11
    [FAST FWD] Reset to 23-JAN-11
    
    PL/SQL procedure successfully completed.
    
    SQL> 


Installation
-------------

Just run the script.

    $ sqlplus / as sysdba @timewarp

Should be installed as SYS.  "Normal" test accounts can then be granted execute permissions.  The script also installs two system triggers to ensure the system clock is reset to the current time on logoff or on startup.


Warning
--------

Obviously a horrible mess will happen if test user is not the sole active database user.  Please do not let this code near a production environment!

