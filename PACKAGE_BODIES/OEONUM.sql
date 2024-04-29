--------------------------------------------------------
--  DDL for Package Body OEONUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEONUM" AS
/* $Header: OEXONUMB.pls 115.2 99/07/16 08:13:52 porting shi $ */

PROCEDURE dummy is
begin
  null;
end;

PROCEDURE CreateSource
(
        sequence_name                   IN VARCHAR2,
        cache                           IN NUMBER,
        min_value                       IN NUMBER,
        start_with                      IN NUMBER,
        return_status                   OUT NUMBER
)
IS

       sql_buffer                       varchar2(240);
       ddl_parameter                    varchar2(240);
       rel_name                         varchar2(240);
       cid integer;
       ad_ddl_found                     boolean := TRUE;
       oexoenum_found                   boolean := TRUE;
       dummy                            varchar2(1);
       package_result                   number;
       x                                number;
       out_status                       varchar2(240);
       out_industry                     varchar2(240);
       out_oracle_schema                varchar2(240);


BEGIN

     BEGIN

	SELECT 'X' into dummy FROM ALL_SEQUENCES
               WHERE SEQUENCE_NAME = sequence_name and rownum=1;


    EXCEPTION

         WHEN NO_DATA_FOUND THEN
              null;

         WHEN OTHERS THEN
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.CreateSource',
			   Operation=>'Create Source',
 			   Message=>'Sql stmt 1');
           return;

    END;



/*
    **  Check if the AD_DDL PL-SQL package is installed,
    **  if it is then call it to create the sequence.
    **  We are doing this for caompatibility issues. If the AD_DDL
    **  package is not installed then then check to see if the
    **  OEXOENUM package is installed. If it is
    **  then let it create the sequence, else create it manually.
*/

    BEGIN

                SELECT      'X'
                INTO DUMMY
                FROM        ALL_SOURCE
                WHERE       NAME='AD_DDL'
                AND         ROWNUM = 1 ;
    EXCEPTION

         WHEN NO_DATA_FOUND THEN
              ad_ddl_found := FALSE;

         WHEN OTHERS THEN
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.CreateSource',
			   Operation=>'Create Source',
 			   Message=>'Sql stmt 2');
           return;

    END;

    /*
    **  Check if the CREATE_OE_SEQUENCE PL-SQL package is installed,
    **  if it is then call it else create the sequence here.
    **  We are doing this for caompatibility issues, Rel 10.5 is the
    **  one that has the OEXOENUM package installed in, so if we are
    **  sending patches to 10.4.% we need to avoid calling this package.
    */

   if not ad_ddl_found then

      BEGIN
            SELECT      'X'
                INTO DUMMY
                FROM        USER_SOURCE
                WHERE       NAME='OEXOENUM'
                AND         ROWNUM = 1 ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
             oexoenum_found := FALSE;
         WHEN OTHERS THEN
           return_status := -1;
             OEONUM.Raise_Exception(Routine=>'OEONUM.CreateSource',
                           Operation=>'Create Source',
                           Message=>'Sql stmt 3');
           return;
      END;

      if not oexoenum_found then

            sql_buffer := 'CREATE SEQUENCE ' || sequence_name || ' ' ||
                          'NOCACHE ' ||
          	          'MINVALUE ' || to_char(min_value) ||
            	          ' START WITH ' || to_char(start_with) ||
         	          ' INCREMENT BY 1 ' ||
             	          'NOCYCLE ' ||
           	          'ORDER';

             cid := dbms_sql.open_cursor;

             dbms_sql.parse(cid,
                            sql_buffer,
                 	       dbms_sql.v7);

             dbms_sql.close_cursor(cid);

             return_status := 0;
      else  /* oexoenum found */

             sql_buffer := 'BEGIN ' ||
                           'OEXOENUM.CREATE_OE_SEQUENCE ' ||
                           '( sequence_name => :sequence_name, ' ||
                           ' cache => :cache, ' ||
                           'min_value => :min_value, ' ||
                           'start_with => :start_with );' ||
                           'END;';

             cid := dbms_sql.open_cursor;
             dbms_sql.parse(cid,
                       sql_buffer,
                       dbms_sql.v7);

             dbms_sql.bind_variable(cid,':sequence_name',sequence_name);
             dbms_sql.bind_variable(cid,':cache',cache);
             dbms_sql.bind_variable(cid,':min_value',min_value);
             dbms_sql.bind_variable(cid,':start_with',start_with);

             package_result := dbms_sql.execute(cid);

             dbms_sql.close_cursor(cid);

             return_status := 0;

      end if; /* not oexoenum_found */

  else /*  ad_ddl_found */


    /*
    ** Build PL/SQL block for getting the oracle username
    */

       IF FND_INSTALLATION.GET_APP_INFO('FND',out_status,out_industry,
                                    out_oracle_schema) then
          x:=1;
       else
          x:=0;
       end if;

    if x = 0 then /* fnd_installation.get_app_info failed */
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.CreateSource',
                           Operation=>'Create Source',
                           Message=>' get_app_info failed 1');
           return;

    end if;

    ddl_parameter :=   'CREATE SEQUENCE ' || sequence_name || ' ' ||
                  ' NOCACHE ' ||
                  ' MINVALUE ' || to_char(min_value) ||
                  ' START WITH ' || to_char(start_with) ||
                  ' INCREMENT BY 1 ' ||
                  ' NOCYCLE ' ||
                  ' ORDER';


    SELECT RELEASE_NAME INTO Rel_name FROM FND_PRODUCT_GROUPS
	WHERE ROWNUM = 1;


   if( SubStr(Rel_Name,1,4) = '10.6') then
       sql_buffer := 'BEGIN ' ||
      		'AD_DDL.DO_DDL(' ||
		''''||out_oracle_schema||'''' ||
		',''OE'',' ||
		to_char(AD_DDL.CREATE_SEQUENCE) ||
      		','||
   		''''||ddl_parameter||'''' || ');  ' ||
                'END;';
  else
       sql_buffer := 'BEGIN ' ||
                'AD_DDL.DO_DDL(' ||
                ''''||out_oracle_schema||'''' ||
                ',''OE'',' ||
                to_char(AD_DDL.CREATE_SEQUENCE) ||
                ','||
                ''''||ddl_parameter||'''' || ',' ||
                ''''||sequence_name||'''' ||
		 ');  ' ||
                'END;';
  end if;

  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,
                 sql_buffer,
                 dbms_sql.v7);

   package_result := dbms_sql.execute(cid);

   dbms_sql.close_cursor(cid);

   return_status := 0;


   end if; /* not ad_ddl_found   */


EXCEPTION

        WHEN OTHERS THEN
          if dbms_sql.is_open(cid) then
                dbms_sql.close_cursor(cid);
          end if;
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.CreateSource',
                           Operation=>'Create Source',
                           Message=>' Sql Stmt 3');
           return;

END;


PROCEDURE GetNextNumber
(
        sequence_name                   IN VARCHAR2,
        returned_sequence               OUT NUMBER,
        return_status                   OUT NUMBER
)
IS

       sql_buffer                       varchar2(200);
       cid                              number;
       package_result 			number;
       sequence_number                  number;


BEGIN

       sql_buffer :=  'SELECT '  || sequence_name ||
              '.NEXTVAL '                 ||
               ' FROM SYS.DUAL';

        cid := dbms_sql.open_cursor;


        dbms_sql.parse(cid,
                       sql_buffer,
                       dbms_sql.v7);

        dbms_sql.define_column(cid,1,sequence_number);

        package_result := dbms_sql.execute(cid);


       if dbms_sql.fetch_rows(cid) > 0 then
         dbms_sql.column_value(cid,1,sequence_number);
       else
         dbms_sql.close_cursor(cid);
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.GetNextNumber',
                           Operation=>'Get next number',
                           Message=>' Sql stmt 4');
           return;

       end if;


        dbms_sql.close_cursor(cid);

        returned_sequence := sequence_number;

        return_status := 0;


EXCEPTION

        WHEN OTHERS THEN
          if dbms_sql.is_open(cid) then
                dbms_sql.close_cursor(cid);
          end if;
           return_status := -1;
          OEONUM.Raise_Exception(Routine=>'OEONUM.GetNextNumber',
                           Operation=>'Get next number',
                           Message=>' When Others');
           return;

END GetNextNumber;

PROCEDURE GetCurrentNumber
(
        sequence_name                   IN VARCHAR2,
        returned_sequence               OUT NUMBER,
        return_status                   OUT NUMBER
)
IS

       package_result                   number;
       sequence_number                  number;
       l_sequence_name                  VARCHAR2(40);


BEGIN
      l_sequence_name := sequence_name;

	SELECT LAST_NUMBER into sequence_number FROM ALL_SEQUENCES
               WHERE SEQUENCE_NAME = l_sequence_name and rownum=1;

        returned_sequence :=  sequence_number;

        return_status:=0;


EXCEPTION

       WHEN NO_DATA_FOUND THEN
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.GetCurrentNumber',
                           Operation=>'Get current number',
                           Message=>' Sql stmt 5, When no_data_found');
           return;

       WHEN OTHERS        THEN
           return_status := -1;
           OEONUM.Raise_Exception(Routine=>'OEONUM.GetCurrentNumber',
                           Operation=>'Get current number',
                           Message=>' Sql stmt 5, when others');
           return;


END GetCurrentNumber;

PROCEDURE OrderNumberSequence
(
        source_id                       IN NUMBER,
        action                          IN NUMBER,
        cache                           NUMBER DEFAULT 100,
        min_value                       NUMBER DEFAULT 1,
        start_with                      NUMBER DEFAULT 1,
        returned_sequence               OUT NUMBER,
        return_status                   OUT NUMBER
)
IS

       sql_buffer                       varchar2(200);
       cid                              number;
       package_result                   number;
       sequence_name 		        varchar2(30);
       sequence_number                  number(23);


	OE_NUM_BASE_SEQ_NAME 		varchar2(24):='SO_ORDER_NUMBER_SEQUENCE';
	OE_NUM_ACT_CREATE  number:=    1;/* Create order number source */
	OE_NUM_ACT_CURRENT number:=    2;/* Get current order number   */
	OE_NUM_ACT_NEXT    number:=    3;/* Get next order number      */
	OE_NUM_DEFAULT_CACHE number:=  100;
	OE_NUM_DEFAULT_START number:=  1;
	DATABASE_OBJECT_LENGTH        number:=  30;




BEGIN

if source_id is null then
           return_status := -1;
    OEONUM.Raise_Exception(Routine=>'OEONUM.OrderNumberSequence',
                           Operation=>'Order Number Sequence',
                           Message=>' Source id is null ');
           return;

end if;


sequence_name := OE_NUM_BASE_SEQ_NAME || ltrim(rtrim(to_char(source_id)));

if length(sequence_name) > DATABASE_OBJECT_LENGTH then
           return_status := -1;
    OEONUM.Raise_Exception(Routine=>'OEONUM.OrderNumberSequence',
                           Operation=>'Order Number Sequence',
                           Message=>' Sequence Name Length exceeds ');
           return;

end if;


if action = OE_NUM_ACT_CREATE then

   OEONUM.CreateSource(sequence_name => sequence_name,
                       cache => cache,
                       min_value => min_value,
                       start_with => start_with,
                       return_status => return_status);

  elsif action = OE_NUM_ACT_CURRENT then

       OEONUM.GetCurrentNumber(sequence_name => sequence_name,
                               returned_sequence => sequence_number,
                               return_status => return_status);

       returned_sequence:=sequence_number;

  elsif action = OE_NUM_ACT_NEXT    then

       OEONUM.GetNextNumber(sequence_name => sequence_name,
                               returned_sequence => sequence_number,
                               return_status => return_status);

       returned_sequence:=sequence_number;

  else
           return_status := -1;
      OEONUM.Raise_Exception(Routine=>'OEONUM.OrderNumberSequence',
                           Operation=>'Order Number Sequence',
                           Message=>' Invalid Action ');
           return;
end if;

EXCEPTION

    WHEN OTHERS THEN
           return_status := -1;
    OEONUM.Raise_Exception(Routine=>'OEONUM.OrderNumberSequence',
                           Operation=>'Order Number Sequence',
                           Message=>' When Others');
           return;

END OrderNumberSequence;

PROCEDURE Raise_exception
(
        Routine                         IN VARCHAR2,
        Operation                       IN VARCHAR2,
        Message	 			IN VARCHAR2
)
IS

x BOOLEAN;

BEGIN

           x :=OE_MSG.Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION',
				'ROUTINE', Routine);
           x :=OE_MSG.Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION',
				'OPERATION', Operation);
           x :=OE_MSG.Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION',
				'MESSAGE',Message|| ' sqlcode:'||SQLCODE);



END;


END OEONUM;

/
