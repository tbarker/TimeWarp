/*
   Copyright 2011 Thomas Barker

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';

SET serveroutput ON;

CREATE OR REPLACE PACKAGE timewarp
AS
    PROCEDURE reset;

    PROCEDURE jump(
	the_date DATE
    );

    PROCEDURE jump(
	the_date VARCHAR2
    );

    PROCEDURE fwd(
	the_number_of_days  NUMBER
    );

    PROCEDURE fastfwd(
	the_start_date	DATE DEFAULT SYSDATE,
	the_end_date	DATE,
	the_sql		VARCHAR2,
	the_interval	NUMBER DEFAULT 1/24 * 0.478
    );

END timewarp;
/
SHOW ERRORS

CREATE OR REPLACE PACKAGE BODY timewarp
AS
    PROCEDURE reset
    IS
    BEGIN
	EXECUTE IMMEDIATE 'ALTER SYSTEM SET FIXED_DATE = ''NONE''';
    END;

    PROCEDURE jump(
	the_date DATE
    )
    IS
    BEGIN
	EXECUTE IMMEDIATE
	    'ALTER SYSTEM SET FIXED_DATE = '''
		||	to_char( the_date, 'YYYY-MM-DD-HH24:MI:SS' )
		||	''''
	;
    END;

    PROCEDURE jump(
	the_date VARCHAR2
    )
    IS
    BEGIN
	timewarp.jump( to_date( the_date, 'DD-MM-YYYY' ) );
    END;

    PROCEDURE fwd(
	the_number_of_days NUMBER 
    )
    IS
    BEGIN
	timewarp.jump( SYSDATE + the_number_of_days );
    END;

    PROCEDURE fastfwd(
	the_start_date	DATE DEFAULT SYSDATE,
	the_end_date	DATE,
	the_sql		VARCHAR2,
	-- Unnatural not quite 27m default interval
	the_interval	NUMBER DEFAULT 1/24 * 0.478 
    )
    IS
    BEGIN
	timewarp.jump( the_start_date );
	dbms_output.put_line( '[FAST FWD] Starting at ' || SYSDATE );

	WHILE ( SYSDATE <  the_end_date )
	LOOP
	    DECLARE
		err_num NUMBER;
		err_msg VARCHAR2(100);
	    BEGIN
		EXECUTE IMMEDIATE the_sql;
	    EXCEPTION
		WHEN OTHERS THEN
		    timewarp.reset;
		    err_num := SQLCODE;
		    err_msg := SUBSTR(SQLERRM, 1, 100);
		    raise_application_error(
			-20001,
			'Error ' || err_num || ' - ' || err_msg,
			TRUE
		    );
	    END;

	    timewarp.fwd( the_interval );
	END LOOP;

	dbms_output.put_line( '[FAST FWD] Ending with ' || SYSDATE );

	timewarp.reset;
	dbms_output.put_line( '[FAST FWD] Reset to ' || SYSDATE );
    END;

END timewarp;
/
SHOW ERRORS

CREATE OR REPLACE TRIGGER clean_up_time_logoff
BEFORE LOGOFF
ON DATABASE
BEGIN
    timewarp.reset;
END;
/
SHOW ERRORS

CREATE OR REPLACE TRIGGER clean_up_time_start
AFTER STARTUP
ON DATABASE
BEGIN
    timewarp.reset;
END;
/
SHOW ERRORS

CREATE OR REPLACE PUBLIC SYNONYM timewarp FOR timewarp
/
SHOW ERRORS

QUIT;

