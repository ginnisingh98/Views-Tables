--------------------------------------------------------
--  DDL for Package Body ECE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_UTILITIES" AS
-- $Header: ECEUTILB.pls 120.2 2005/09/29 08:56:02 arsriniv ship $


/************************************************************
This procedure tests the code conversion functionality.
The procedure will return the five external values
for the single Internal value provide for Outbound
(cDirection=OUT).  It will return the single internal
value for the five external values provided for
Inbound (cDirection=IN).
************************************************************/
PROCEDURE TEST_XREF_API (
        cDirection          IN     VARCHAR2, -- Values: OUT or IN
	cTransaction_code   IN     VARCHAR2,
        cView_name          IN     VARCHAR2,
        cView_column        IN     VARCHAR2,
        cInternal_value     IN OUT NOCOPY VARCHAR2,
        cKey1_value         IN     VARCHAR2,
        cKey2_value         IN     VARCHAR2,
        cKey3_value         IN     VARCHAR2,
        cKey4_value         IN     VARCHAR2,
        cKey5_value         IN     VARCHAR2,
        cExt1_value         IN OUT NOCOPY VARCHAR2,
        cExt2_value         IN OUT NOCOPY VARCHAR2,
        cExt3_value         IN OUT NOCOPY VARCHAR2,
        cExt4_value         IN OUT NOCOPY VARCHAR2,
        cExt5_value         IN OUT NOCOPY VARCHAR2)

/*
This procedure will test the code conversion routines.
     * Direction must be:
         OUT - To test outbound xref (Internal to External)
         IN  - To test inbound xref (External to Internal)

     * View Name is the name of the EDI view in outbound transactions
       and the Base Applications (AP,AR,PO,OE,etc) Open API
       interface table name in inbound transactions.

     * View Columns is the column in the EDI view for outbound
       transactions and the Base Applications Open API
       interface table column for inbound transactions.

     * If testing for an outbound transaction, then this API
       requires the cInternal_value and optionally
       cKey1_value through cKey5_value parameters.

     * If testing for an inbound transaction, then this API
       requires at least cExt1_value and optionally
       cExt2_value thourgh cExt5_value and also optioanlly
       Key1_value through cKey5_value parameters.

     * If testing an outbound transaction, cExt1_value
       through cExt5_value will be the out parameters
       returned to the calling procedure.  If testing
       for an inbound transaction, then cInternal_value
       will be the only out parameter.
*/

is

   l_return_status		VARCHAR2(15);
   l_msg_count			NUMBER;
   l_msg_data			VARCHAR2(2000);
   cCategory_code		VARCHAR2(50);
   xProgress 			VARCHAR2(20);

begin

    xProgress := 'TEST_XREF-10';
    /**********************************************
     Get the category code based on the table and
     column specified.
    **********************************************/
    select distinct cat.xref_category_code
    into  cCategory_code
    from  ece_interface_tables t,
          ece_interface_columns col,
          ece_xref_categories cat
    where t.interface_table_id = col.interface_table_id
    and   cat.xref_category_id = col.xref_category_id
    and   t.transaction_type = cTransaction_code
    and   col.base_table_name = cView_name
    and   col.base_column_name = cView_column;

xProgress := 'TEST_XREF-20';

/*************************************************
If the direction is OUT (outbound), then test the
conversion from internal values to external values.
*************************************************/
if cDirection = 'OUT' then
	xProgress := 'TEST_XREF-30';
         EC_Code_Conversion_PVT.Convert_from_int_to_ext
                       (  p_api_version_number	=> 1.0,
                          p_return_status	=> l_return_status,
                          p_msg_count		=> l_msg_count,
                          p_msg_data		=> l_msg_data,
                          p_Category     	=> cCategory_code,
                          p_Int_val		=> cInternal_value,
			  p_Key1		=> cKey1_value,
			  p_Key2		=> cKey2_value,
			  p_Key3		=> cKey3_value,
			  p_Key4		=> cKey4_value,
			  p_Key5		=> cKey5_value,
                          p_Ext_val1		=> cExt1_value,
                          p_Ext_val2		=> cExt2_value,
                          p_Ext_val3		=> cExt3_value,
                          p_Ext_val4		=> cExt4_value,
                          p_Ext_val5		=> cExt5_value
                       );

/*************************************************
If the direction is IN (inbound), then test the
conversion from external to internal values.
*************************************************/
elsif cDirection = 'IN' then
	xProgress := 'TEST_XREF-40';
        EC_Code_Conversion_PVT.Convert_from_ext_to_int
                       (  p_api_version_number	=> 1.0,
                          p_return_status	=> l_return_status,
                          p_msg_count		=> l_msg_count,
                          p_msg_data		=> l_msg_data,
                          p_Category     	=> cCategory_code,
                          p_Ext_val1		=> cExt1_value,
                          p_Ext_val2		=> cExt2_value,
                          p_Ext_val3		=> cExt3_value,
                          p_Ext_val4		=> cExt4_value,
                          p_Ext_val5		=> cExt5_value,
			  p_Key1		=> cKey1_value,
			  p_Key2		=> cKey2_value,
			  p_Key3		=> cKey3_value,
			  p_Key4		=> cKey4_value,
			  p_Key5		=> cKey5_value,
                          p_Int_val		=> cInternal_value
                       );

end if;
	xProgress := 'TEST_XREF-50';

EXCEPTION
  when others then
    app_exception.raise_exception;

end TEST_XREF_API;


/**********************************************************
This procedure will validate the seed data contained in the
EDI Gateway data dictionary against what the database
actually has.

If bErrors_found returns a TRUE, then the calling procedure
should so a select from ECE_OUTPUT where run_id = iRun_id
to see the errors.

The calling routine should also clean up the ECE_OUTPUT
table when finished by deleting the records where
run_id = iRun_id.
*********************************************************/
PROCEDURE SEED_DATA_CHECK (
	cTransaction_code	IN  VARCHAR2,
        bErrors_found		OUT NOCOPY BOOLEAN,
        iRun_id			OUT NOCOPY NUMBER,
	bCheckLength		IN  BOOLEAN DEFAULT FALSE,
	bCheckDatatype		IN  BOOLEAN DEFAULT FALSE,
	bInsertErrors           IN  BOOLEAN DEFAULT FALSE)
is
        cursor c_atc(my_table VARCHAR2, my_column VARCHAR2) is
	select data_length,
	       data_type
	from   user_tab_columns
	where  column_name = my_column
	  and  table_name  = my_table;

	cursor c_inc is
	select
		eit.interface_table_name,
		eit.key_column_name,
		eic.interface_column_name,
		eic.base_table_name,
		eic.base_column_nAme,
		eic.data_type,
		eic.width
	from 	ece_interface_tables eit,
		ece_interface_columns eic
	where 	eit.interface_table_id = eic.interface_table_id
	and	eit.transaction_type   = UPPER(cTransaction_code)
	order by eit.interface_table_name;

	eic_rec	c_inc%ROWTYPE;

	cursor c_int_table is
	select
		eit.interface_table_name,
		eit.start_number,
		eit.output_level,
		eit.key_column_name
	from
		ece_interface_tables eit
	where
		eit.transaction_type = UPPER(cTransaction_code);

	eit_rec	c_int_table%ROWTYPE;


	cursor test_output_level(xTrans VARCHAR2, xLevel VARCHAR2) is
	  select lookup_type
 	  from   ece_lookup_values
	  where  lookup_type = 'OUTPUT_LEVEL_'||xTrans
	  and    lookup_code = xLevel;

        x_width		NUMBER;
	x_datatype	VARCHAR2(30);
        x_msg		VARCHAR2(300);
        x_errcol	VARCHAR2(60);
	x_errtbl	VARCHAR2(60);
	x_errdatatype	VARCHAR2(30);
	xTemp		VARCHAR2(80);
	xCurTable	VARCHAR2(50) := 'X';
	xDirection	VARCHAR2(10);
	cDirection 	VARCHAR2(10);

        col_not_found   EXCEPTION;
        wrong_datatype	EXCEPTION;
	bad_width	EXCEPTION;
        no_output_level EXCEPTION;
	key_col_not_defined EXCEPTION;

begin
    /****************************************************
     Get the next run id.  This is the key for this run
     in the ece_output table.
    ****************************************************/
    select ece_output_runs_s.nextval
    into iRun_id from dual;

  begin
    select direction
    into   xDirection
    from   ece_interface_tables
    where  transaction_type = cTransaction_code
    and    output_level = '1';

    if xDirection = 'I' then
      cDirection := 'IN';
    else
      cDirection := 'OUT';
    end if;
  end;


  /*****************************************************
   Verify that the transaction code is defined in
   ece_lookup_values with lookup_type=DOCUMENT
  *****************************************************/
  begin
     select lookup_code
     into   xTemp
     from   ece_lookup_values
     where  lookup_type = 'DOCUMENT'
     and    lookup_code = cTransaction_code;

     EXCEPTION
	when NO_DATA_FOUND then
	    bErrors_found := TRUE;
	    x_msg := 'SEED: Document '||cTransaction_code||' not defined in ece_lookup_values';

	    if bInsertErrors then
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
	    end if;
  end;


  /*****************************************************
   Verify that the document types are defined in
   ece_lookup_values with lookup_type=xxx:DOCUMENT_TYPE
  *****************************************************/
  begin
     select lookup_code
     into   xTemp
     from   ece_lookup_values
     where  lookup_type = cTransaction_code||':DOCUMENT_TYPE';


     EXCEPTION
	when NO_DATA_FOUND then
	    bErrors_found := TRUE;
	    if bInsertErrors then
 	     x_msg := 'SEED: Document types for '||cTransaction_code||' not defined in ece_lookup_values';
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
	    end if;

	when TOO_MANY_ROWS then
	    -- This is because the select could return more than one row causing
	    -- an exception.  We want to trap that exception because returning
	    -- more than one row is a good thing.
	    null;

  end;


  /******************************************************
   First verify that all of the output levels defined
   in the ece_interface_tables table have corresponding
   lookup records in ece_lookup_values.
  ******************************************************/
  OPEN c_int_table;
  LOOP
  FETCH c_int_table into eit_rec;

  EXIT WHEN c_int_table%NOTFOUND;

	open test_output_level(cTransaction_code,eit_rec.output_level);
	fetch test_output_level into xTemp;

	begin
	  if test_output_level%ROWCOUNT = 0 then
	   close test_output_level;
	   RAISE no_output_level;
	  end if;

	  close test_output_level;

	  EXCEPTION
	   WHEN no_output_level then
            bErrors_found := TRUE;
	    if bInsertErrors then
	     x_msg := 'SEED: Output level not defined in ECE_LOOKUP_VALUES: '||eit_rec.output_level;
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
	    end if;
	   WHEN others then
            bErrors_found := TRUE;
	    if bInsertErrors then
	     x_msg := 'SEED: Err in output_level check: '||SQLERRM;
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
  	    end if;
	end;

  END LOOP; -- c_int_table loop

  /**********************************************************
   Start verifying the seeded data in ece_interface_tables,
   ece_interface_columns, and ece_source_data_loc against
   the database.
  **********************************************************/
  OPEN c_inc;
  LOOP
  FETCH c_inc into eic_rec;

    IF c_inc%ROWCOUNT = 0 THEN
      CLOSE c_inc;
      RAISE no_data_found;
    END IF;

    EXIT WHEN c_inc%NOTFOUND;

   /**********************************************************
    The Interface_column_name is only relevant for outbound
    transactions.  For inbound, interface_column_name is only
    a name used in the pl/sql table and therefor does not have
    to be tested.
   **********************************************************/
   if cDirection = 'OUT' then

        /**********************************************************
	 Check to ensure all of the view columns seeded actually exist
	 in the database
        **********************************************************/
	if eic_rec.base_table_name is NOT NULL and
	   eic_rec.base_column_name is NOT NULL then

         OPEN c_atc(eic_rec.base_table_name, eic_rec.base_column_name);
         FETCH c_atc into x_width, x_datatype;

         BEGIN

           IF c_atc%ROWCOUNT = 0 THEN
            CLOSE c_atc;
	    RAISE col_not_found;
           END IF;

           CLOSE c_atc;
         EXCEPTION
           WHEN col_not_found THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.base_table_name;
             x_errcol := eic_rec.base_column_name;
             x_msg := 'SEED: Column not found for '||x_errtbl ||'.'||x_errcol;
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
	    end if;
	  END;
	end if;

        /**********************************************************
	 Check to ensure all of the interface table columns seeded
         actually exist in the database
        **********************************************************/
      IF eic_rec.interface_table_name is NOT NULL
         and eic_rec.interface_column_name is NOT NULL then

         OPEN c_atc(eic_rec.interface_table_name, eic_rec.interface_column_name);
         FETCH c_atc into x_width, x_datatype;

         BEGIN

           IF c_atc%ROWCOUNT = 0 THEN
            CLOSE c_atc;
	    RAISE col_not_found;
           END IF;

           CLOSE c_atc;

           if bCheckDatatype then
	    IF x_datatype <> eic_rec.data_type OR eic_rec.data_type IS NULL THEN
             RAISE wrong_datatype;
            END IF;
	   end if;

	   if bCheckLength then
	    if x_width < eic_rec.width then
 	     RAISE bad_width;
	    END IF;
	   end if;

	   if eic_rec.key_column_name is null
	    and xCurTable <> eic_rec.interface_table_name then
	     RAISE key_col_not_defined;
	   end if;

         EXCEPTION
           WHEN col_not_found THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.interface_table_name;
             x_errcol := eic_rec.interface_column_name;
             x_msg := 'SEED: Column not found for '||x_errtbl ||'.'||x_errcol;
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
	    end if;
           WHEN wrong_datatype THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.interface_table_name;
             x_errcol := eic_rec.interface_column_name;
             x_errdatatype := eic_rec.data_type;

             x_msg := 'SEED: Wrong data type for '||x_errtbl ||'.'||
		x_errcol||' Seeded datatype: '||x_errdatatype||' Database datatype: '||
		x_datatype;

             insert into ece_output (run_id,line_id,text)
               values (iRun_id,
		       ece_output_lines_s.nextval,
		       x_msg);
	    end if;

           WHEN bad_width THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.interface_table_name;
             x_errcol := eic_rec.interface_column_name;

             x_msg := 'SEED: Interface column '||x_errtbl ||'.'||
		x_errcol||' too short. Seeded: '||eic_rec.width||' Database: '||x_width;

             insert into ece_output (run_id,line_id,text)
              values (iRun_id,
		      ece_output_lines_s.nextval,
		      x_msg);
	    end if;
	   WHEN key_col_not_defined then
	    bErrors_found := TRUE;
	    if bInsertErrors then
	     xCurTable := eic_rec.interface_table_name;
             x_errtbl := eic_rec.interface_table_name;
             x_msg := 'SEED: Key column not defined for '||x_errtbl;
             insert into ece_output (run_id,line_id,text)
             values (iRun_id,
		    ece_output_lines_s.nextval,
		    x_msg);
	    end if;

         END;
      END IF;  --  if eic_rec.interface_table_name is not null

   elsif cDirection = 'IN' then

      IF eic_rec.base_table_name is NOT NULL
         and eic_rec.base_column_name is NOT NULL then

         OPEN c_atc(eic_rec.base_table_name, eic_rec.base_column_name);
         FETCH c_atc into x_width, x_datatype;

         BEGIN
          IF NOT c_atc%FOUND THEN
           CLOSE c_atc;
	   RAISE col_not_found;
          END IF;

          CLOSE c_atc;


	  if bCheckDatatype then
           IF x_datatype <> eic_rec.data_type THEN
            x_errdatatype := eic_rec.data_type;
	    RAISE wrong_datatype;
           END IF;
	  end if;

	  if bCheckLength then
 	   if x_width < eic_rec.width then
 	    RAISE bad_width;
	   END IF;
	  end if;

         EXCEPTION
           WHEN col_not_found THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.base_table_name;
             x_errcol := eic_rec.base_column_name;
             x_msg := 'SEED: Seeded column '||x_errtbl ||'.'||x_errcol||' not found.';
             insert into ece_output (run_id,line_id,text)
              values (iRun_id,
		      ece_output_lines_s.nextval,
		      x_msg);
	    end if;

           WHEN wrong_datatype THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.base_table_name;
             x_errcol := eic_rec.base_column_name;
             x_msg := 'SEED: Wrong data type for '||x_errtbl ||'.'||
		   x_errcol||' Seeded datatype: '||x_errdatatype||' Database datatype: '||
		   x_datatype;
             insert into ece_output (run_id,line_id,text)
              values (iRun_id,
		      ece_output_lines_s.nextval,
		      x_msg);
	    end if;

           WHEN bad_width THEN
	    bErrors_found := TRUE;
	    if bInsertErrors then
             x_errtbl := eic_rec.base_table_name;
             x_errcol := eic_rec.base_column_name;

             x_msg := 'SEED: Interface column '||x_errtbl ||'.'||
		x_errcol||' too short. Seeded: '||eic_rec.width||' Database: '||x_width;

             insert into ece_output (run_id,line_id,text)
              values (iRun_id,
		      ece_output_lines_s.nextval,
		      x_msg);
	    end if;
         END;
    END IF;  -- if ic_rec.base_table_name is NOT NULL
   end if; -- if cDirection = 'OUT' elsif cDirection = 'IN'
  END LOOP;

EXCEPTION

  WHEN others THEN
    IF c_inc%ISOPEN THEN
      CLOSE c_inc;
    END IF;
    IF c_atc%ISOPEN THEN
      CLOSE c_atc;
    END IF;
    RAISE;
end SEED_DATA_CHECK;



/**********************************************************
This procedure will return the location code, reference1,
and reference2 values for the Entity (Customer, Supplier,
or Bank) specified.

p_Entity_type must be one of the following values:
	CUSTOMER
	SUPPLIER
	BANK

**********************************************************/
PROCEDURE TEST_TP_LOOKUP (
		p_Entity_site_id	IN	NUMBER,
		p_Entity_type		IN	VARCHAR2,
		p_location_code		OUT NOCOPY	VARCHAR2,
		p_reference_ext1	OUT NOCOPY 	VARCHAR2,
		p_reference_ext2	OUT NOCOPY	VARCHAR2)

IS
			l_return_status  VARCHAR2(30);
			l_msg_count      NUMBER;
			l_msg_data 	 VARCHAR2(240);
			l_info_type	 VARCHAR2(30);

BEGIN

/**********************************************************
   The org context must be setup before running this procedure!

   p_Entity_id is the address_id if Customer or
   vendor_site_id if Supplier.
**********************************************************/
  if upper(p_Entity_type) = 'CUSTOMER' then
     l_info_type := EC_Trading_Partner_PVT.G_CUSTOMER;
  elsif upper(p_Entity_type) = 'SUPPLIER' then
     l_info_type := EC_Trading_Partner_PVT.G_SUPPLIER;
  elsif upper(p_Entity_type) = 'BANK' then
     l_info_type := EC_Trading_Partner_PVT.G_BANK;
  end if;

   ec_trading_Partner_pvt.get_tp_location_code(
			p_api_version_number	=> 1.0,
			p_return_status		=> l_return_status,
			p_msg_count		=> l_msg_count,
			p_msg_data		=> l_msg_data,
			p_location_code_ext	=> p_location_code,
			p_info_type		=> l_info_type,
			p_reference_ext1	=> p_reference_ext1,
			p_reference_ext2	=> p_reference_ext2,
			p_entity_address_id	=> p_Entity_site_id);

end TEST_TP_LOOKUP;



/*************************************************************
This procedure will return the Entity and Entity Site Id for
translator and location code specified.

Entity_type must be one of the following:

                        --------Returned values-------
	Entity Type     Entity_id	Entity_site_id
        -------------------------------------------------
	CUSTOMER	CUSTOMER_ID	ADDRESS_ID
	SUPPLIER	VENDOR_ID       VENDOR_SITE_ID
	BANK		BANK_BRANCH_ID
************************************************************/
PROCEDURE TEST_LOCATION_CODE (
	p_Translator_code	IN	VARCHAR2,
	p_Location_code		IN	VARCHAR2,
	p_Entity_type		IN	VARCHAR2,
	l_entity_id	     	OUT NOCOPY	NUMBER,
	l_entity_address_id  	OUT NOCOPY	NUMBER)

IS

	l_return_status      VARCHAR2(30);
	l_msg_count          NUMBER;
	l_msg_data 	     VARCHAR2(240);
	l_info_type	     VARCHAR2(30);

BEGIN

  if upper(p_Entity_type) = 'CUSTOMER' then
     l_info_type := EC_Trading_Partner_PVT.G_CUSTOMER;
  elsif upper(p_Entity_type) = 'SUPPLIER' then
     l_info_type := EC_Trading_Partner_PVT.G_SUPPLIER;
  elsif upper(p_Entity_type) = 'BANK' then
     l_info_type := EC_Trading_Partner_PVT.G_BANK;
  end if;

   ec_trading_Partner_pvt.get_tp_address(
			p_api_version_number	=> 1.0,
			p_return_status		=> l_return_status,
			p_msg_count		=> l_msg_count,
			p_msg_data		=> l_msg_data,
			p_translator_code	=> p_translator_code,
			p_location_code_ext	=> p_location_code,
			p_info_type		=> l_info_type,
			p_entity_id		=> l_entity_id,
			p_entity_address_id	=> l_entity_address_id);


end TEST_LOCATION_CODE;

/*******************************************************************
This procedure will read a flatfile and create records in ECE_OUTPUT
with the values of the data based on the  EDI Gateway data dictionary.
*******************************************************************/
PROCEDURE verify_flatfile(
      p_run_id           IN NUMBER,
      p_map_id		 IN NUMBER,
      p_Transaction_Type IN VARCHAR2,
      p_File_path        IN VARCHAR2,
      p_Filename         IN VARCHAR2) IS

      xProgress                     VARCHAR2(80);

      l_rec_number                  NUMBER;
      l_cur_pos                     NUMBER;
      l_data_length                 NUMBER;

      l_data_value		    VARCHAR2(32000) := NULL;
      l_insert_stmt		    VARCHAR2(2000);
      c_current_line                VARCHAR2(5000);

      u_file_handle                 utl_file.file_type;
      x_num                         NUMBER;
      l_initial_position	    NUMBER := 100;
      l_start_position              NUMBER;
      l_end_position                NUMBER;
      l_prv_record_num              NUMBER := -1;

/* Bug 1668518
** In the following cursor,added a check on the external_level
** in ece_interface_columns with the ece_external_levels table.
*/
      CURSOR c_file_column(
      			p_trans_type VARCHAR2,
      			p_map_id NUMBER,
      			p_record_num NUMBER
      			) IS
         SELECT      eic.interface_column_name,
                     eic.base_table_name,
                     eic.base_column_name,
                     eic.record_number,
                     eic.position,
                     eic.conversion_sequence       conversion_seq,
                     eic.record_layout_code,
                     eic.record_layout_qualifier,
                     eic.conversion_group_id,
                     eic.data_type,
                     eic.width                     data_length
         FROM        ece_interface_columns      eic,
                     ece_interface_tables       eit,
                     ece_level_matrices		elm,
		     ece_external_levels	eel
         WHERE       eit.interface_table_id     = eic.interface_table_id AND
         	     eit.transaction_type       = p_trans_type AND
                     eit.interface_table_id 	= elm.interface_table_id AND
		     elm.external_level_id	= eel.external_level_id AND
	       	     eel.external_level         = eic.external_level   AND
		     eel.map_id			= p_map_id AND
                     eic.record_number          = p_record_num
         ORDER BY    eic.record_number,eic.position;


    -- ***********************************************************************
    -- This procedure read data from an ASCII based on the data dictionary
    -- ECE_INTERFACE_COLUMNS table.  It will then produce a report of
    -- the value for each of the EDI element for the transaction.
    -- ***********************************************************************
    -- Algorithm:
    --
    -- Loop
    --    Read a line from the flat file
    --
    --    Find out what is the record number
    --    Execute cursor to find all elements on this record.
    --    Report the value of each of the element
    --
    -- End Loop
    -- ***********************************************************************

        BEGIN
        xProgress := 'RDATA-10-1000';
	u_file_handle := utl_file.fopen(p_File_path, p_Filename, 'r',5000);

	LOOP
           xProgress := 'RDATA-10-1010';
	   x_num := x_num + 1;

           xProgress := 'RDATA-10-1020';
       	   if x_num > 1000000000
	   then
               -- go into a inifinate loop, exit immediately
               xProgress := 'RDATA-10-1030';
               EXIT;
            end if;

            xProgress := 'RDATA-10-1040';
            utl_file.get_line(u_file_handle, c_current_line);

            xProgress := 'RDATA-10-1050';
            l_rec_number := TO_NUMBER(SUBSTRB(c_current_line,
                                 ece_flatfile_pvt.g_record_num_start,
                                 ece_flatfile_pvt.g_record_num_length));

             -- ***************************************
             -- cursor position should be at the
             -- end of common key
             -- ***************************************
            xProgress := 'RDATA-10-1060';
            l_cur_pos := ece_flatfile_pvt.g_common_key_length;

            -- ***************************************
            --  Execute cursor to find all elements for
            --  this record
            -- ***************************************
            xProgress := 'RDATA-10-1070';
            FOR interface_data_rec IN c_file_column(
            					p_trans_type    => p_transaction_type,
            					p_map_id	=> p_map_id,
                                           	p_record_num => l_rec_number) LOOP
               xProgress := 'RDATA-10-1080';
               l_data_length := interface_data_rec.data_length;
               xProgress := 'RDATA-10-1090';
               l_data_value := RTRIM(SUBSTRB(c_current_line, l_cur_pos + 1, l_data_length));

               -- *******************************
               -- WARNING:
               -- Since the data is from a file
               -- NULL data is padded with BLANKS.
               -- Remove them
               -- *******************************
               xProgress := 'RDATA-10-1100';
               IF REPLACE(l_data_value, ' ') IS NULL THEN
                  xProgress := 'RDATA-10-1110';
                  l_data_value := NULL;
               END IF;

               xProgress := 'RDATA-10-1120';
               l_cur_pos := l_cur_pos + l_data_length;

               /* DERIVE the position for the data element */
               if interface_data_rec.Record_number <> l_prv_record_num
               then
                    -- bug # 927944/948754 fix
		  l_end_position := l_initial_position;
	       end if;
	      	  l_start_position := l_end_position + 1;
		  l_end_position := l_end_position + nvl(interface_data_rec.data_length ,0);

               xProgress := 'RDATA-10-1130';
               l_insert_stmt :=
                         LPAD(interface_data_rec.Record_number,4,'0') ||'  '||
                         LPAD(interface_data_rec.Position,4) ||' '||
                         LPAD(interface_data_rec.data_length,4) ||' '||
                         LPAD(l_start_position,5,' ') ||'  '|| -- Bug # 948754 fix
                         RPAD(interface_data_rec.interface_column_name,45,' ') ||'    '||
                         l_data_value;
               EC_DEBUG.PL(3, 'l_insert_stmt: ', l_insert_stmt);

               xProgress := 'RDATA-10-1140';
               INSERT into ece_output( run_id, line_id, text)
                 VALUES(p_run_id, ece_output_runs_s.nextval, l_insert_stmt);

               xProgress := 'RDATA-10-1150';
               l_insert_stmt := NULL;
               l_prv_record_num := interface_data_rec.Record_number;
            END LOOP;
        END LOOP;

        -- finish utl_file.get_line
EXCEPTION
				-- this exception handler is to handle end of file
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('EC','ECE_PROGRAM_ERROR');
            FND_MESSAGE.SET_TOKEN('PROGRESS_LEVEL',xProgress);
            APP_EXCEPTION.RAISE_EXCEPTION;

END verify_flatfile;


PROCEDURE set_installation(
      p_transaction     IN VARCHAR2,
      p_short_name      IN VARCHAR2,
      p_status          IN VARCHAR2)
IS

/**************************************************************
  This procedure will enable or disable an EDI transaction
  so it will/will not be visible from all forms within EDI.
  It does not delete any records, it simply sets flags.
  Parameters:
   p_transaction  - The EDI Transaction Code (i.e. POI,INO)
   p_short_name   - The Short Name of the Concurrent program
                    defined for the transaction.
   p_status       - Status you want to set.  Valid values
                    are ENABLE or DISABLE
**************************************************************/

   /* Application Id for EDI Gateway is 175 */
   p_application_id     NUMBER := 175;
   xProgress            VARCHAR2(20);
   c_installed_flag     VARCHAR2(1);
   temp_enabled_flag    VARCHAR2(1);
   not_in_main_flag     VARCHAR2(1) := 'N';
   not_in_upg_flag      VARCHAR2(1) := 'N';
   new_status           VARCHAR2(1);

   BEGIN
      xProgress := 'UTILB-10-1000';
      BEGIN
         /* Make sure status passed in is valid */
         xProgress := 'UTILB-10-1010';
         IF UPPER(p_status) = 'ENABLE' THEN
            xProgress := 'UTILB-10-1020';
            new_status := 'Y';
         ELSIF UPPER(p_status) = 'DISABLE' THEN
            xProgress := 'UTILB-10-1030';
            new_status := 'N';
         ELSE
            xProgress := 'UTILB-10-1040';
            -- dbms_output.put_line('ERR: Bad Status passed in. Must be ENABLE or DISABLE');
   	      app_exception.raise_exception;
         END IF;

         /* Make sure transaction type passed in exists */
         xProgress := 'UTILB-10-1050';
         SELECT installed_flag INTO c_installed_flag
         FROM   ece_interface_tables
         WHERE  transaction_Type = p_transaction AND
                output_level = 1 AND
                ROWNUM = 1;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --	dbms_output.put_line('ERR: Transaction Code not found');
            -- Oops, it looks like the transaction is not found in ECE_INTERFACE_TABLES.
            not_in_main_flag := 'Y';

         WHEN OTHERS THEN
            --	dbms_output.put_line(xProgress);
            --	dbms_output.put_line('ERR: Transaction Check: '||SQLERRM);
            app_exception.raise_exception;
      END;

      BEGIN
         BEGIN
            IF not_in_main_flag = 'Y' THEN
               /* Make sure transaction type passed in exists */
               xProgress := 'UTILB-10-1050';
               SELECT installed_flag INTO c_installed_flag
               FROM   ece_interface_tbls_upg
               WHERE  transaction_Type = p_transaction AND
                      output_level = 1 AND
                      ROWNUM = 1;
            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               app_exception.raise_exception;
         END;

          /* Make sure concurrent program exists */
          xProgress := 'UTILB-10-1060';
          SELECT enabled_flag INTO temp_enabled_flag
          FROM   fnd_concurrent_programs
          WHERE  application_id          = p_application_id AND
                 concurrent_program_name = UPPER(p_short_name);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --	dbms_output.put_line(xProgress);
            --	dbms_output.put_line('ERR: Concurrent Program does not exist');
            IF not_in_main_flag = 'Y' THEN
               app_exception.raise_exception;
            ELSE
               not_in_upg_flag := 'Y';
            END IF;

         WHEN OTHERS THEN
            --	dbms_output.put_line(xProgress);
            --	dbms_output.put_line('ERR: Conc Program Check: '||SQLERRM);
            app_exception.raise_exception;
      END;

      BEGIN
         /* Now go and update the EDI tables */
         xProgress := 'UTILB-10-1070';
         IF not_in_upg_flag = 'N' THEN
            UPDATE ece_interface_tbls_upg
            SET    installed_flag = new_status
            WHERE  transaction_type = p_transaction;
         END IF;

         IF not_in_main_flag = 'N' THEN
            UPDATE ece_interface_tables
            SET    installed_flag = new_status
            WHERE  transaction_type = p_transaction;
         END IF;

         xProgress := 'UTILB-10-1080';
         UPDATE ece_lookup_values
         SET    enabled_flag = new_status
         WHERE  lookup_type = 'DOCUMENT' AND
                lookup_code = p_transaction;

      EXCEPTION
         WHEN OTHERS THEN
            --   dbms_output.put_line(xProgress);
            --   dbms_output.put_line('ERR: Error updating EC tables');
            app_exception.raise_exception;

      END;

      xProgress := 'UTILB-10-1100';
      fnd_program.enable_program(p_short_name,'EC',new_status);

   EXCEPTION
      WHEN OTHERS THEN
         -- dbms_output.put_line('ERR: '||xProgress);
         app_exception.raise_exception;

   END set_installation;

END ECE_UTILITIES;


/
