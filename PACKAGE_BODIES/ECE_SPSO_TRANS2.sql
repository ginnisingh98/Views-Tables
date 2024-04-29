--------------------------------------------------------
--  DDL for Package Body ECE_SPSO_TRANS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_SPSO_TRANS2" AS
-- $Header: ECSPSO2B.pls 120.2.12010000.9 2014/11/18 05:53:49 mazhong ship $
/* Bug 2064311
  Added the parameter batch id to the proceudre
  POPULATE_SUPPLIER_SCHED_API2 and cursor sch_hdr_c
  to improve performance
*/


 PROCEDURE POPULATE_SUPPLIER_SCHED_API2
	(
	p_communication_method	IN  VARCHAR2,	-- EDI
	p_transaction_type	IN  VARCHAR2,	-- plan SPSO, ship SSSO
	p_document_type		IN  VARCHAR2,	-- plan SPS, ship SSS
	p_run_id		IN  NUMBER,
	p_schedule_id		IN  INTEGER default 0,
        p_batch_id              IN   NUMBER  ) -- Bug 2064311
 IS
    xProgress 			VARCHAR2(30) := NULL;
    cOutput_path		varchar2(120);
    l_transaction_number        NUMBER;         -- Bug 1742567
    exclude_zero_schedule_from_ff VARCHAR2(1) := 'N';  -- 2944455
  /****************************
  **	SELECT HEADER        **
  ****************************/

  CURSOR sch_hdr_c IS
   SELECT
	CSH.SCHEDULE_ID			SCHEDULE_ID,
	CSH.SCHEDULE_TYPE		SCHEDULE_TYPE,
        CSH.BATCH_ID                    BATCH_ID   --Bug 2064311
   FROM
	ECE_TP_DETAILS		ETD,
	PO_VENDOR_SITES		PVS,
	CHV_SCHEDULE_HEADERS	CSH
   WHERE
	CSH.SCHEDULE_STATUS	=	'CONFIRMED'
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--   AND EXISTS (SELECT 1 FROM CHV_ITEM_ORDERS CIO
--                WHERE CIO.SCHEDULE_ID = CSH.SCHEDULE_ID)
   AND	ETD.EDI_FLAG		=	'Y'     -- EDI
   AND	ETD.DOCUMENT_ID		=	P_TRANSACTION_TYPE --ship SSSO,plan SPSO
   AND  P_TRANSACTION_TYPE	=	DECODE(SCHEDULE_TYPE, 'SHIP_SCHEDULE',
						'SSSO', 'SPSO')
   AND 	((CSH.SCHEDULE_ID	=	P_SCHEDULE_ID
			AND		P_SCHEDULE_ID <> 0)
   OR		(P_SCHEDULE_ID	= 0
		AND	NVL(CSH.COMMUNICATION_CODE,'NONE') IN  ('BOTH','EDI')))
   AND  CSH.BATCH_ID = decode(P_BATCH_ID,0,CSH.BATCH_ID,P_BATCH_ID) --Bug 2064311
   AND	CSH.VENDOR_SITE_ID	=	PVS.VENDOR_SITE_ID
   AND	PVS.TP_HEADER_ID	=	ETD.TP_HEADER_ID
   AND	ETD.DOCUMENT_ID		=	DECODE(SCHEDULE_TYPE, 'SHIP_SCHEDULE',
						'SSSO', 'SPSO')
   FOR	UPDATE;
/*
   AND 	ECC.DIRECTION		=	'O'	-- outbound
   AND	ECC.ENABLED_FLAG	=	'Y'	-- outbound transmission enabled
   AND	ECC.DOCUMENT_ID		=	P_TRANSACTION_TYPE --ship SSSO,plan SPSO
   AND	ECC.TRANSMISSION_METHOD	=	P_COMMUNICATION_METHOD  -- EDI
   AND	ECC.ENTITY_TYPE		=	'SUPPLIER'	-- destination
   AND  CSH.VENDOR_ID		=	ECC.ENTITY_ID
   AND  CSH.VENDOR_SITE_ID	=	ECC.ENTITY_SITE_ID
*/



   BEGIN				-- begin header block

   EC_DEBUG.PUSH('ECE_SPSO_TRANS2.populate_supplier_sched_api2');
   EC_DEBUG.PL(3, 'p_communication_method: ', p_communication_method);
   EC_DEBUG.PL(3, 'p_transaction_type: ',p_transaction_type);
   EC_DEBUG.PL(3, 'p_document_type: ',p_document_type);
   EC_DEBUG.PL(3, 'p_run_id: ',p_run_id);
   EC_DEBUG.PL(3, 'p_schedule_id: ',p_schedule_id);

   -- Retreive the system profile option ECE_OUT_FILE_PATH.  This will
   -- be the directory where the output file will be written.
   -- NOTE: THIS DIRECTORY MUST BE SPECIFIED IN THE PARAMETER utl_file_dir IN
   -- THE INIT.ORA FILE.  Refer to the Oracle7 documentation for more information
   -- on the package UTL_FILE.

   xProgress := 'SPSO2B-10-0100';
   fnd_profile.get('ECE_OUT_FILE_PATH',
		cOutput_path);
   EC_DEBUG.PL(3, 'cOutput_path: ',cOutput_path);

   -- BUG 14733044: if cusor in ece_spso_trans1.Put_Data_To_Output_Table()
   -- retrieve no data, roll back to this savepoint
   savepoint PSSAPI2;

   -- This sets up temporary files for FND_FILE to write.
   -- These are only used if the program is run from SQL*Plus.
   xProgress := 'SPSO2B-10-0110';
   fnd_file.put_names('spso_log.tmp','spso_out.tmp',cOutput_path);

     <<header>>
     xProgress := 'SPSO2B-10-1000';
     FOR rec_hdr IN sch_hdr_c LOOP

      /**************************
      **    SELECT ITEM	       **
      **************************/

      DECLARE
	x_item_detail_sequence		NUMBER :=0;
        x_item_order                    NUMBER;
        x_item_detail                   NUMBER;
        CURSOR  sch_item_c  IS
          SELECT
	     CSI.SCHEDULE_ID		SCHEDULE_ID,
	     CSI.SCHEDULE_ITEM_ID	SCHEDULE_ITEM_ID
           FROM
	     CHV_SCHEDULE_ITEMS 	CSI
           WHERE
	     CSI.SCHEDULE_ID		=	REC_HDR.SCHEDULE_ID;
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--        AND EXISTS (SELECT 1 FROM CHV_ITEM_ORDERS CIO
--                    WHERE CIO.SCHEDULE_ID = CSI.SCHEDULE_ID);

           BEGIN			-- begin item block
	     <<item>>
             xProgress := 'SPSO2B-10-1020';
--bug12422231 Uncommented to tackle the case when profile is 'Y'
--(regression from 11893659)
               Select count(*)
                Into x_item_order
                From chv_item_orders
              Where schedule_id = rec_hdr.schedule_id;
-- 2944455
              fnd_profile.get('ECE_SPSO_EXCLUDE_ZERO_SCHEDULE_FROM_FF',exclude_zero_schedule_from_ff);
                   If NVL(exclude_zero_schedule_from_ff,'N')<>'Y' then
                      exclude_zero_schedule_from_ff := 'N';
                   End If;
           If ((exclude_zero_schedule_from_ff = 'N')
--bug12422231 Modified to tackle the case when profile is 'Y'
--(regression from 11893659)
	        OR
                (exclude_zero_schedule_from_ff = 'Y' AND x_item_order > 0)
	       )  Then
   	     FOR  rec_item  IN  sch_item_c  LOOP


	     	/*********************************************************
	     	**	select the last sequence number assigned to	**
	     	**	the detail record of the same schedule item id.	**
	     	*********************************************************/

                  xProgress := 'SPSO2B-10-1030';
--bug12422231 Uncommented to tackle the case when profile is 'Y'
--(regression from 11893659)
                Select      count(schedule_id)
                Into        x_item_detail
                From        chv_item_orders
                Where       schedule_id = rec_hdr.schedule_id
                And         schedule_item_id = rec_item.schedule_item_id;
-- 2944455
                IF ((exclude_zero_schedule_from_ff = 'N')
		   OR
--bug12422231 Modified to tackle the case when profile is 'Y'
--(regression from 11893659)

                   (exclude_zero_schedule_from_ff = 'Y' AND x_item_order > 0 AND x_item_detail > 0)
		    )   Then

               BEGIN
		  SELECT 	max(schedule_item_detail_sequence)
		  INTO		x_item_detail_sequence
		  FROM		ece_spso_item_det
		  WHERE		schedule_id	=  rec_item.schedule_id
		  AND		schedule_item_id=  rec_item.schedule_item_id;
		EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		    x_item_detail_sequence := 0;
		END;				--  select max sequence block
                EC_DEBUG.PL(3, 'x_item_detail_sequence: ',x_item_detail_sequence);

	      /**************************************
	      **   SELECT AND INSERT ITEM DETAIL   **
	      **************************************/

	      DECLARE

		TYPE	tbl_hz_type 	IS TABLE OF VARCHAR2(25)
					INDEX BY BINARY_INTEGER;
		tbl_desc		tbl_hz_type;
		tbl_start		tbl_hz_type;
		tbl_end			tbl_hz_type;
		tbl_for			tbl_hz_type;
		tbl_rel			tbl_hz_type;
		tbl_tot			tbl_hz_type;
		rec_hz			chv_horizontal_schedules%ROWTYPE;

		x_max_col		number := 60;
		x_min_col		number := 1;
		x_detail_category	varchar2(25);
		x_bucket_descriptor	varchar2(25);

	      BEGIN				-- begin item detail block

		BEGIN				-- begin select detail block


		  /****************
		  ** Description **
		  ****************/

		  -- Get BUCET_DESCRIPTION from CHV_HORIZONTAL_SCHEDULES

                  xProgress := 'SPSO2B-10-1040';

		  --DBMS_OUTPUT.PUT_LINE('LN1 '||sqlcode);
		  SELECT	*
		  INTO	    rec_hz
		  FROM	    chv_horizontal_schedules
		  WHERE	    schedule_item_id 	= rec_item.schedule_item_id
		  AND	    schedule_id		= rec_item.schedule_id
		  AND	    row_type		= 'BUCKET_DESCRIPTOR';


                  xProgress := 'SPSO2B-10-1050';
		  -- Copy BUCKET_DESCRIPTOR into PL/SQL table

		  tbl_desc(1)	:=	rec_hz.column1;
		  tbl_desc(2)	:=	rec_hz.column2;
		  tbl_desc(3)	:=	rec_hz.column3;
		  tbl_desc(4)	:=	rec_hz.column4;
		  tbl_desc(5)	:=	rec_hz.column5;
		  tbl_desc(6)	:=	rec_hz.column6;
		  tbl_desc(7)	:=	rec_hz.column7;
		  tbl_desc(8)	:=	rec_hz.column8;
		  tbl_desc(9)	:=	rec_hz.column9;
		  tbl_desc(10)	:=	rec_hz.column10;
		  tbl_desc(11)	:=	rec_hz.column11;
		  tbl_desc(12)	:=	rec_hz.column12;
		  tbl_desc(13)	:=	rec_hz.column13;
		  tbl_desc(14)	:=	rec_hz.column14;
		  tbl_desc(15)	:=	rec_hz.column15;
		  tbl_desc(16)	:=	rec_hz.column16;
		  tbl_desc(17)	:=	rec_hz.column17;
		  tbl_desc(18)	:=	rec_hz.column18;
		  tbl_desc(19)	:=	rec_hz.column19;
		  tbl_desc(20)	:=	rec_hz.column20;
		  tbl_desc(21)	:=	rec_hz.column21;
		  tbl_desc(22)	:=	rec_hz.column22;
		  tbl_desc(23)	:=	rec_hz.column23;
		  tbl_desc(24)	:=	rec_hz.column24;
		  tbl_desc(25)	:=	rec_hz.column25;
		  tbl_desc(26)	:=	rec_hz.column26;
		  tbl_desc(27)	:=	rec_hz.column27;
		  tbl_desc(28)	:=	rec_hz.column28;
		  tbl_desc(29)	:=	rec_hz.column29;
		  tbl_desc(30)	:=	rec_hz.column30;
		  tbl_desc(31)	:=	rec_hz.column31;
		  tbl_desc(32)	:=	rec_hz.column32;
		  tbl_desc(33)	:=	rec_hz.column33;
		  tbl_desc(34)	:=	rec_hz.column34;
		  tbl_desc(35)	:=	rec_hz.column35;
		  tbl_desc(36)	:=	rec_hz.column36;
		  tbl_desc(37)	:=	rec_hz.column37;
		  tbl_desc(38)	:=	rec_hz.column38;
		  tbl_desc(39)	:=	rec_hz.column39;
		  tbl_desc(40)	:=	rec_hz.column40;
		  tbl_desc(41)	:=	rec_hz.column41;
		  tbl_desc(42)	:=	rec_hz.column42;
		  tbl_desc(43)	:=	rec_hz.column43;
		  tbl_desc(44)	:=	rec_hz.column44;
		  tbl_desc(45)	:=	rec_hz.column45;
		  tbl_desc(46)	:=	rec_hz.column46;
		  tbl_desc(47)	:=	rec_hz.column47;
		  tbl_desc(48)	:=	rec_hz.column48;
		  tbl_desc(49)	:=	rec_hz.column49;
		  tbl_desc(50)	:=	rec_hz.column50;
		  tbl_desc(51)	:=	rec_hz.column51;
		  tbl_desc(52)	:=	rec_hz.column52;
		  tbl_desc(53)	:=	rec_hz.column53;
		  tbl_desc(54)	:=	rec_hz.column54;
		  tbl_desc(55)	:=	rec_hz.column55;
		  tbl_desc(56)	:=	rec_hz.column56;
		  tbl_desc(57)	:=	rec_hz.column57;
		  tbl_desc(58)	:=	rec_hz.column58;
		  tbl_desc(59)	:=	rec_hz.column59;
		  tbl_desc(60)	:=	rec_hz.column60;

                  EC_DEBUG.PL(3, 'tbl_desc(1): ',tbl_desc(1));
                  EC_DEBUG.PL(3, 'tbl_desc(2): ',tbl_desc(2));
                  EC_DEBUG.PL(3, 'tbl_desc(3): ',tbl_desc(3));
                  EC_DEBUG.PL(3, 'tbl_desc(4): ',tbl_desc(4));
                  EC_DEBUG.PL(3, 'tbl_desc(5): ',tbl_desc(5));
                  EC_DEBUG.PL(3, 'tbl_desc(6): ',tbl_desc(6));
                  EC_DEBUG.PL(3, 'tbl_desc(7): ',tbl_desc(7));
                  EC_DEBUG.PL(3, 'tbl_desc(8): ',tbl_desc(8));
                  EC_DEBUG.PL(3, 'tbl_desc(9): ',tbl_desc(9));
                  EC_DEBUG.PL(3, 'tbl_desc(10): ',tbl_desc(10));
                  EC_DEBUG.PL(3, 'tbl_desc(11): ',tbl_desc(11));
                  EC_DEBUG.PL(3, 'tbl_desc(12): ',tbl_desc(12));
                  EC_DEBUG.PL(3, 'tbl_desc(13): ',tbl_desc(13));
                  EC_DEBUG.PL(3, 'tbl_desc(14): ',tbl_desc(14));
                  EC_DEBUG.PL(3, 'tbl_desc(15): ',tbl_desc(15));
                  EC_DEBUG.PL(3, 'tbl_desc(16): ',tbl_desc(16));
                  EC_DEBUG.PL(3, 'tbl_desc(17): ',tbl_desc(17));
                  EC_DEBUG.PL(3, 'tbl_desc(18): ',tbl_desc(18));
                  EC_DEBUG.PL(3, 'tbl_desc(19): ',tbl_desc(19));
                  EC_DEBUG.PL(3, 'tbl_desc(20): ',tbl_desc(20));
                  EC_DEBUG.PL(3, 'tbl_desc(21): ',tbl_desc(21));
                  EC_DEBUG.PL(3, 'tbl_desc(22): ',tbl_desc(22));
                  EC_DEBUG.PL(3, 'tbl_desc(23): ',tbl_desc(23));
                  EC_DEBUG.PL(3, 'tbl_desc(24): ',tbl_desc(24));
                  EC_DEBUG.PL(3, 'tbl_desc(25): ',tbl_desc(25));
                  EC_DEBUG.PL(3, 'tbl_desc(26): ',tbl_desc(26));
                  EC_DEBUG.PL(3, 'tbl_desc(27): ',tbl_desc(27));
                  EC_DEBUG.PL(3, 'tbl_desc(28): ',tbl_desc(28));
                  EC_DEBUG.PL(3, 'tbl_desc(29): ',tbl_desc(29));
                  EC_DEBUG.PL(3, 'tbl_desc(30): ',tbl_desc(30));
                  EC_DEBUG.PL(3, 'tbl_desc(31): ',tbl_desc(31));
                  EC_DEBUG.PL(3, 'tbl_desc(32): ',tbl_desc(32));
                  EC_DEBUG.PL(3, 'tbl_desc(33): ',tbl_desc(33));
                  EC_DEBUG.PL(3, 'tbl_desc(34): ',tbl_desc(34));
                  EC_DEBUG.PL(3, 'tbl_desc(35): ',tbl_desc(35));
                  EC_DEBUG.PL(3, 'tbl_desc(36): ',tbl_desc(36));
                  EC_DEBUG.PL(3, 'tbl_desc(37): ',tbl_desc(37));
                  EC_DEBUG.PL(3, 'tbl_desc(38): ',tbl_desc(38));
                  EC_DEBUG.PL(3, 'tbl_desc(39): ',tbl_desc(39));
                  EC_DEBUG.PL(3, 'tbl_desc(40): ',tbl_desc(40));
                  EC_DEBUG.PL(3, 'tbl_desc(41): ',tbl_desc(41));
                  EC_DEBUG.PL(3, 'tbl_desc(42): ',tbl_desc(42));
                  EC_DEBUG.PL(3, 'tbl_desc(43): ',tbl_desc(43));
                  EC_DEBUG.PL(3, 'tbl_desc(44): ',tbl_desc(44));
                  EC_DEBUG.PL(3, 'tbl_desc(45): ',tbl_desc(45));
                  EC_DEBUG.PL(3, 'tbl_desc(46): ',tbl_desc(46));
                  EC_DEBUG.PL(3, 'tbl_desc(47): ',tbl_desc(47));
                  EC_DEBUG.PL(3, 'tbl_desc(48): ',tbl_desc(48));
                  EC_DEBUG.PL(3, 'tbl_desc(49): ',tbl_desc(49));
                  EC_DEBUG.PL(3, 'tbl_desc(50): ',tbl_desc(50));
                  EC_DEBUG.PL(3, 'tbl_desc(51): ',tbl_desc(51));
                  EC_DEBUG.PL(3, 'tbl_desc(52): ',tbl_desc(52));
                  EC_DEBUG.PL(3, 'tbl_desc(53): ',tbl_desc(53));
                  EC_DEBUG.PL(3, 'tbl_desc(54): ',tbl_desc(54));
                  EC_DEBUG.PL(3, 'tbl_desc(55): ',tbl_desc(55));
                  EC_DEBUG.PL(3, 'tbl_desc(56): ',tbl_desc(56));
                  EC_DEBUG.PL(3, 'tbl_desc(57): ',tbl_desc(57));
                  EC_DEBUG.PL(3, 'tbl_desc(58): ',tbl_desc(58));
                  EC_DEBUG.PL(3, 'tbl_desc(59): ',tbl_desc(59));
                  EC_DEBUG.PL(3, 'tbl_desc(60): ',tbl_desc(60));
		  /*****************
		  **  Start Date  **
		  *****************/

		  -- Get START_DATE from CHV_HORIZONTAL_SCHEDULES

                  xProgress := 'SPSO2B-10-1060';

		  BEGIN				-- START DATE select block
                    xProgress := 'SPSO2B-10-1070';
		    --DBMS_OUTPUT.PUT_LINE('LN2 '||sqlcode);
		    SELECT	*
		    INTO	rec_hz
		    FROM	chv_horizontal_schedules
		    WHERE	schedule_item_id = rec_item.schedule_item_id
		    AND	        schedule_id	 = rec_item.schedule_id
		    AND	        row_type	 = 'BUCKET_START_DATE';


                    xProgress := 'SPSO2B-10-1080';
		    -- Copy BUCKET_START_DATE into PL/SQL table

		    tbl_start(1)	:=	rec_hz.column1;
		    tbl_start(2)	:=	rec_hz.column2;
		    tbl_start(3)	:=	rec_hz.column3;
		    tbl_start(4)	:=	rec_hz.column4;
		    tbl_start(5)	:=	rec_hz.column5;
		    tbl_start(6)	:=	rec_hz.column6;
		    tbl_start(7)	:=	rec_hz.column7;
		    tbl_start(8)	:=	rec_hz.column8;
		    tbl_start(9)	:=	rec_hz.column9;
		    tbl_start(10)	:=	rec_hz.column10;
		    tbl_start(11)	:=	rec_hz.column11;
		    tbl_start(12)	:=	rec_hz.column12;
		    tbl_start(13)	:=	rec_hz.column13;
		    tbl_start(14)	:=	rec_hz.column14;
		    tbl_start(15)	:=	rec_hz.column15;
		    tbl_start(16)	:=	rec_hz.column16;
		    tbl_start(17)	:=	rec_hz.column17;
		    tbl_start(18)	:=	rec_hz.column18;
		    tbl_start(19)	:=	rec_hz.column19;
		    tbl_start(20)	:=	rec_hz.column20;
		    tbl_start(21)	:=	rec_hz.column21;
		    tbl_start(22)	:=	rec_hz.column22;
		    tbl_start(23)	:=	rec_hz.column23;
		    tbl_start(24)	:=	rec_hz.column24;
		    tbl_start(25)	:=	rec_hz.column25;
		    tbl_start(26)	:=	rec_hz.column26;
		    tbl_start(27)	:=	rec_hz.column27;
		    tbl_start(28)	:=	rec_hz.column28;
		    tbl_start(29)	:=	rec_hz.column29;
		    tbl_start(30)	:=	rec_hz.column30;
		    tbl_start(31)	:=	rec_hz.column31;
		    tbl_start(32)	:=	rec_hz.column32;
		    tbl_start(33)	:=	rec_hz.column33;
		    tbl_start(34)	:=	rec_hz.column34;
		    tbl_start(35)	:=	rec_hz.column35;
		    tbl_start(36)	:=	rec_hz.column36;
		    tbl_start(37)	:=	rec_hz.column37;
		    tbl_start(38)	:=	rec_hz.column38;
		    tbl_start(39)	:=	rec_hz.column39;
		    tbl_start(40)	:=	rec_hz.column40;
		    tbl_start(41)	:=	rec_hz.column41;
		    tbl_start(42)	:=	rec_hz.column42;
		    tbl_start(43)	:=	rec_hz.column43;
		    tbl_start(44)	:=	rec_hz.column44;
		    tbl_start(45)	:=	rec_hz.column45;
		    tbl_start(46)	:=	rec_hz.column46;
		    tbl_start(47)	:=	rec_hz.column47;
		    tbl_start(48)	:=	rec_hz.column48;
		    tbl_start(49)	:=	rec_hz.column49;
		    tbl_start(50)	:=	rec_hz.column50;
		    tbl_start(51)	:=	rec_hz.column51;
		    tbl_start(52)	:=	rec_hz.column52;
		    tbl_start(53)	:=	rec_hz.column53;
		    tbl_start(54)	:=	rec_hz.column54;
		    tbl_start(55)	:=	rec_hz.column55;
		    tbl_start(56)	:=	rec_hz.column56;
		    tbl_start(57)	:=	rec_hz.column57;
		    tbl_start(58)	:=	rec_hz.column58;
		    tbl_start(59)	:=	rec_hz.column59;
		    tbl_start(60)	:=	rec_hz.column60;

                  EC_DEBUG.PL(3, 'tbl_start(1): ',tbl_start(1));
                  EC_DEBUG.PL(3, 'tbl_start(2): ',tbl_start(2));
                  EC_DEBUG.PL(3, 'tbl_start(3): ',tbl_start(3));
                  EC_DEBUG.PL(3, 'tbl_start(4): ',tbl_start(4));
                  EC_DEBUG.PL(3, 'tbl_start(5): ',tbl_start(5));
                  EC_DEBUG.PL(3, 'tbl_start(6): ',tbl_start(6));
                  EC_DEBUG.PL(3, 'tbl_start(7): ',tbl_start(7));
                  EC_DEBUG.PL(3, 'tbl_start(8): ',tbl_start(8));
                  EC_DEBUG.PL(3, 'tbl_start(9): ',tbl_start(9));
                  EC_DEBUG.PL(3, 'tbl_start(10): ',tbl_start(10));
                  EC_DEBUG.PL(3, 'tbl_start(11): ',tbl_start(11));
                  EC_DEBUG.PL(3, 'tbl_start(12): ',tbl_start(12));
                  EC_DEBUG.PL(3, 'tbl_start(13): ',tbl_start(13));
                  EC_DEBUG.PL(3, 'tbl_start(14): ',tbl_start(14));
                  EC_DEBUG.PL(3, 'tbl_start(15): ',tbl_start(15));
                  EC_DEBUG.PL(3, 'tbl_start(16): ',tbl_start(16));
                  EC_DEBUG.PL(3, 'tbl_start(17): ',tbl_start(17));
                  EC_DEBUG.PL(3, 'tbl_start(18): ',tbl_start(18));
                  EC_DEBUG.PL(3, 'tbl_start(19): ',tbl_start(19));
                  EC_DEBUG.PL(3, 'tbl_start(20): ',tbl_start(20));
                  EC_DEBUG.PL(3, 'tbl_start(21): ',tbl_start(21));
                  EC_DEBUG.PL(3, 'tbl_start(22): ',tbl_start(22));
                  EC_DEBUG.PL(3, 'tbl_start(23): ',tbl_start(23));
                  EC_DEBUG.PL(3, 'tbl_start(24): ',tbl_start(24));
                  EC_DEBUG.PL(3, 'tbl_start(25): ',tbl_start(25));
                  EC_DEBUG.PL(3, 'tbl_start(26): ',tbl_start(26));
                  EC_DEBUG.PL(3, 'tbl_start(27): ',tbl_start(27));
                  EC_DEBUG.PL(3, 'tbl_start(28): ',tbl_start(28));
                  EC_DEBUG.PL(3, 'tbl_start(29): ',tbl_start(29));
                  EC_DEBUG.PL(3, 'tbl_start(30): ',tbl_start(30));
                  EC_DEBUG.PL(3, 'tbl_start(31): ',tbl_start(31));
                  EC_DEBUG.PL(3, 'tbl_start(32): ',tbl_start(32));
                  EC_DEBUG.PL(3, 'tbl_start(33): ',tbl_start(33));
                  EC_DEBUG.PL(3, 'tbl_start(34): ',tbl_start(34));
                  EC_DEBUG.PL(3, 'tbl_start(35): ',tbl_start(35));
                  EC_DEBUG.PL(3, 'tbl_start(36): ',tbl_start(36));
                  EC_DEBUG.PL(3, 'tbl_start(37): ',tbl_start(37));
                  EC_DEBUG.PL(3, 'tbl_start(38): ',tbl_start(38));
                  EC_DEBUG.PL(3, 'tbl_start(39): ',tbl_start(39));
                  EC_DEBUG.PL(3, 'tbl_start(40): ',tbl_start(40));
                  EC_DEBUG.PL(3, 'tbl_start(41): ',tbl_start(41));
                  EC_DEBUG.PL(3, 'tbl_start(42): ',tbl_start(42));
                  EC_DEBUG.PL(3, 'tbl_start(43): ',tbl_start(43));
                  EC_DEBUG.PL(3, 'tbl_start(44): ',tbl_start(44));
                  EC_DEBUG.PL(3, 'tbl_start(45): ',tbl_start(45));
                  EC_DEBUG.PL(3, 'tbl_start(46): ',tbl_start(46));
                  EC_DEBUG.PL(3, 'tbl_start(47): ',tbl_start(47));
                  EC_DEBUG.PL(3, 'tbl_start(48): ',tbl_start(48));
                  EC_DEBUG.PL(3, 'tbl_start(49): ',tbl_start(49));
                  EC_DEBUG.PL(3, 'tbl_start(50): ',tbl_start(50));
                  EC_DEBUG.PL(3, 'tbl_start(51): ',tbl_start(51));
                  EC_DEBUG.PL(3, 'tbl_start(52): ',tbl_start(52));
                  EC_DEBUG.PL(3, 'tbl_start(53): ',tbl_start(53));
                  EC_DEBUG.PL(3, 'tbl_start(54): ',tbl_start(54));
                  EC_DEBUG.PL(3, 'tbl_start(55): ',tbl_start(55));
                  EC_DEBUG.PL(3, 'tbl_start(56): ',tbl_start(56));
                  EC_DEBUG.PL(3, 'tbl_start(57): ',tbl_start(57));
                  EC_DEBUG.PL(3, 'tbl_start(58): ',tbl_start(58));
                  EC_DEBUG.PL(3, 'tbl_start(59): ',tbl_start(59));
                  EC_DEBUG.PL(3, 'tbl_start(60): ',tbl_start(60));


		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		      NULL;
		  END;				-- START DATE select block

		  /*************
		  ** End Date **
		  *************/

		  -- Get END_DATE from CHV_HORIZONTAL_SCHEDULES

                  xProgress := 'SPSO2B-10-1090';

		  BEGIN					-- END DATE select block
                    xProgress := 'SPSO2B-10-1100';
		    --DBMS_OUTPUT.PUT_LINE('LN3 '||sqlcode);
		    SELECT        *
		    INTO	  rec_hz
		    FROM	  chv_horizontal_schedules
		    WHERE	  schedule_item_id 	= rec_item.schedule_item_id
		    AND		  schedule_id		= rec_item.schedule_id
		    AND	  	  row_type		= 'BUCKET_END_DATE';


                    xProgress := 'SPSO2B-10-1110';
		    -- Copy BUCKET_END_DATE into PL/SQL table

		    tbl_end(1)	:=	rec_hz.column1;
		    tbl_end(2)	:=	rec_hz.column2;
		    tbl_end(3)	:=	rec_hz.column3;
		    tbl_end(4)	:=	rec_hz.column4;
		    tbl_end(5)	:=	rec_hz.column5;
		    tbl_end(6)	:=	rec_hz.column6;
		    tbl_end(7)	:=	rec_hz.column7;
		    tbl_end(8)	:=	rec_hz.column8;
		    tbl_end(9)	:=	rec_hz.column9;
		    tbl_end(10)	:=	rec_hz.column10;
		    tbl_end(11)	:=	rec_hz.column11;
		    tbl_end(12)	:=	rec_hz.column12;
		    tbl_end(13)	:=	rec_hz.column13;
		    tbl_end(14)	:=	rec_hz.column14;
		    tbl_end(15)	:=	rec_hz.column15;
		    tbl_end(16)	:=	rec_hz.column16;
		    tbl_end(17)	:=	rec_hz.column17;
		    tbl_end(18)	:=	rec_hz.column18;
		    tbl_end(19)	:=	rec_hz.column19;
		    tbl_end(20)	:=	rec_hz.column20;
		    tbl_end(21)	:=	rec_hz.column21;
		    tbl_end(22)	:=	rec_hz.column22;
		    tbl_end(23)	:=	rec_hz.column23;
		    tbl_end(24)	:=	rec_hz.column24;
		    tbl_end(25)	:=	rec_hz.column25;
		    tbl_end(26)	:=	rec_hz.column26;
		    tbl_end(27)	:=	rec_hz.column27;
		    tbl_end(28)	:=	rec_hz.column28;
		    tbl_end(29)	:=	rec_hz.column29;
		    tbl_end(30)	:=	rec_hz.column30;
		    tbl_end(31)	:=	rec_hz.column31;
		    tbl_end(32)	:=	rec_hz.column32;
		    tbl_end(33)	:=	rec_hz.column33;
		    tbl_end(34)	:=	rec_hz.column34;
		    tbl_end(35)	:=	rec_hz.column35;
		    tbl_end(36)	:=	rec_hz.column36;
		    tbl_end(37)	:=	rec_hz.column37;
		    tbl_end(38)	:=	rec_hz.column38;
		    tbl_end(39)	:=	rec_hz.column39;
		    tbl_end(40)	:=	rec_hz.column40;
		    tbl_end(41)	:=	rec_hz.column41;
		    tbl_end(42)	:=	rec_hz.column42;
		    tbl_end(43)	:=	rec_hz.column43;
		    tbl_end(44)	:=	rec_hz.column44;
		    tbl_end(45)	:=	rec_hz.column45;
		    tbl_end(46)	:=	rec_hz.column46;
		    tbl_end(47)	:=	rec_hz.column47;
		    tbl_end(48)	:=	rec_hz.column48;
		    tbl_end(49)	:=	rec_hz.column49;
		    tbl_end(50)	:=	rec_hz.column50;
		    tbl_end(51)	:=	rec_hz.column51;
		    tbl_end(52)	:=	rec_hz.column52;
		    tbl_end(53)	:=	rec_hz.column53;
		    tbl_end(54)	:=	rec_hz.column54;
		    tbl_end(55)	:=	rec_hz.column55;
		    tbl_end(56)	:=	rec_hz.column56;
		    tbl_end(57)	:=	rec_hz.column57;
		    tbl_end(58)	:=	rec_hz.column58;
		    tbl_end(59)	:=	rec_hz.column59;
		    tbl_end(60)	:=	rec_hz.column60;


                  EC_DEBUG.PL(3, 'tbl_end(1): ',tbl_end(1));
                  EC_DEBUG.PL(3, 'tbl_end(2): ',tbl_end(2));
                  EC_DEBUG.PL(3, 'tbl_end(3): ',tbl_end(3));
                  EC_DEBUG.PL(3, 'tbl_end(4): ',tbl_end(4));
                  EC_DEBUG.PL(3, 'tbl_end(5): ',tbl_end(5));
                  EC_DEBUG.PL(3, 'tbl_end(6): ',tbl_end(6));
                  EC_DEBUG.PL(3, 'tbl_end(7): ',tbl_end(7));
                  EC_DEBUG.PL(3, 'tbl_end(8): ',tbl_end(8));
                  EC_DEBUG.PL(3, 'tbl_end(9): ',tbl_end(9));
                  EC_DEBUG.PL(3, 'tbl_end(10): ',tbl_end(10));
                  EC_DEBUG.PL(3, 'tbl_end(11): ',tbl_end(11));
                  EC_DEBUG.PL(3, 'tbl_end(12): ',tbl_end(12));
                  EC_DEBUG.PL(3, 'tbl_end(13): ',tbl_end(13));
                  EC_DEBUG.PL(3, 'tbl_end(14): ',tbl_end(14));
                  EC_DEBUG.PL(3, 'tbl_end(15): ',tbl_end(15));
                  EC_DEBUG.PL(3, 'tbl_end(16): ',tbl_end(16));
                  EC_DEBUG.PL(3, 'tbl_end(17): ',tbl_end(17));
                  EC_DEBUG.PL(3, 'tbl_end(18): ',tbl_end(18));
                  EC_DEBUG.PL(3, 'tbl_end(19): ',tbl_end(19));
                  EC_DEBUG.PL(3, 'tbl_end(20): ',tbl_end(20));
                  EC_DEBUG.PL(3, 'tbl_end(21): ',tbl_end(21));
                  EC_DEBUG.PL(3, 'tbl_end(22): ',tbl_end(22));
                  EC_DEBUG.PL(3, 'tbl_end(23): ',tbl_end(23));
                  EC_DEBUG.PL(3, 'tbl_end(24): ',tbl_end(24));
                  EC_DEBUG.PL(3, 'tbl_end(25): ',tbl_end(25));
                  EC_DEBUG.PL(3, 'tbl_end(26): ',tbl_end(26));
                  EC_DEBUG.PL(3, 'tbl_end(27): ',tbl_end(27));
                  EC_DEBUG.PL(3, 'tbl_end(28): ',tbl_end(28));
                  EC_DEBUG.PL(3, 'tbl_end(29): ',tbl_end(29));
                  EC_DEBUG.PL(3, 'tbl_end(30): ',tbl_end(30));
                  EC_DEBUG.PL(3, 'tbl_end(31): ',tbl_end(31));
                  EC_DEBUG.PL(3, 'tbl_end(32): ',tbl_end(32));
                  EC_DEBUG.PL(3, 'tbl_end(33): ',tbl_end(33));
                  EC_DEBUG.PL(3, 'tbl_end(34): ',tbl_end(34));
                  EC_DEBUG.PL(3, 'tbl_end(35): ',tbl_end(35));
                  EC_DEBUG.PL(3, 'tbl_end(36): ',tbl_end(36));
                  EC_DEBUG.PL(3, 'tbl_end(37): ',tbl_end(37));
                  EC_DEBUG.PL(3, 'tbl_end(38): ',tbl_end(38));
                  EC_DEBUG.PL(3, 'tbl_end(39): ',tbl_end(39));
                  EC_DEBUG.PL(3, 'tbl_end(40): ',tbl_end(40));
                  EC_DEBUG.PL(3, 'tbl_end(41): ',tbl_end(41));
                  EC_DEBUG.PL(3, 'tbl_end(42): ',tbl_end(42));
                  EC_DEBUG.PL(3, 'tbl_end(43): ',tbl_end(43));
                  EC_DEBUG.PL(3, 'tbl_end(44): ',tbl_end(44));
                  EC_DEBUG.PL(3, 'tbl_end(45): ',tbl_end(45));
                  EC_DEBUG.PL(3, 'tbl_end(46): ',tbl_end(46));
                  EC_DEBUG.PL(3, 'tbl_end(47): ',tbl_end(47));
                  EC_DEBUG.PL(3, 'tbl_end(48): ',tbl_end(48));
                  EC_DEBUG.PL(3, 'tbl_end(49): ',tbl_end(49));
                  EC_DEBUG.PL(3, 'tbl_end(50): ',tbl_end(50));
                  EC_DEBUG.PL(3, 'tbl_end(51): ',tbl_end(51));
                  EC_DEBUG.PL(3, 'tbl_end(52): ',tbl_end(52));
                  EC_DEBUG.PL(3, 'tbl_end(53): ',tbl_end(53));
                  EC_DEBUG.PL(3, 'tbl_end(54): ',tbl_end(54));
                  EC_DEBUG.PL(3, 'tbl_end(55): ',tbl_end(55));
                  EC_DEBUG.PL(3, 'tbl_end(56): ',tbl_end(56));
                  EC_DEBUG.PL(3, 'tbl_end(57): ',tbl_end(57));
                  EC_DEBUG.PL(3, 'tbl_end(58): ',tbl_end(58));
                  EC_DEBUG.PL(3, 'tbl_end(59): ',tbl_end(59));
                  EC_DEBUG.PL(3, 'tbl_end(60): ',tbl_end(60));

		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			NULL;
		      RAISE;
		  END;					-- END DATE select block
		  /*********************
		  ** Release Quantity **
		  *********************/

		  -- Get RELEASE_QUANTITY from CHV_HORIZONTAL_SCHEDULES

                  xProgress := 'SPSO2B-10-1120';

		  BEGIN				-- RELEASE QUANTITY block
                    xProgress := 'SPSO2B-10-1130';
		    SELECT  *
		    INTO    rec_hz
		    FROM    chv_horizontal_schedules
		    WHERE   schedule_item_id 	= rec_item.schedule_item_id
		    AND	    schedule_id		= rec_item.schedule_id
		    AND	    row_type		= 'RELEASE_QUANTITY';


                    xProgress := 'SPSO2B-10-1140';
		    -- Copy RELEASE_QUANTITY into PL/SQL table

		    tbl_rel(1)	:=	rec_hz.column1;
		    tbl_rel(2)	:=	rec_hz.column2;
		    tbl_rel(3)	:=	rec_hz.column3;
		    tbl_rel(4)	:=	rec_hz.column4;
		    tbl_rel(5)	:=	rec_hz.column5;
		    tbl_rel(6)	:=	rec_hz.column6;
		    tbl_rel(7)	:=	rec_hz.column7;
		    tbl_rel(8)	:=	rec_hz.column8;
		    tbl_rel(9)	:=	rec_hz.column9;
		    tbl_rel(10)	:=	rec_hz.column10;
		    tbl_rel(11)	:=	rec_hz.column11;
		    tbl_rel(12)	:=	rec_hz.column12;
		    tbl_rel(13)	:=	rec_hz.column13;
		    tbl_rel(14)	:=	rec_hz.column14;
		    tbl_rel(15)	:=	rec_hz.column15;
		    tbl_rel(16)	:=	rec_hz.column16;
		    tbl_rel(17)	:=	rec_hz.column17;
		    tbl_rel(18)	:=	rec_hz.column18;
		    tbl_rel(19)	:=	rec_hz.column19;
		    tbl_rel(20)	:=	rec_hz.column20;
		    tbl_rel(21)	:=	rec_hz.column21;
		    tbl_rel(22)	:=	rec_hz.column22;
		    tbl_rel(23)	:=	rec_hz.column23;
		    tbl_rel(24)	:=	rec_hz.column24;
		    tbl_rel(25)	:=	rec_hz.column25;
		    tbl_rel(26)	:=	rec_hz.column26;
		    tbl_rel(27)	:=	rec_hz.column27;
		    tbl_rel(28)	:=	rec_hz.column28;
		    tbl_rel(29)	:=	rec_hz.column29;
		    tbl_rel(30)	:=	rec_hz.column30;
		    tbl_rel(31)	:=	rec_hz.column31;
		    tbl_rel(32)	:=	rec_hz.column32;
		    tbl_rel(33)	:=	rec_hz.column33;
		    tbl_rel(34)	:=	rec_hz.column34;
		    tbl_rel(35)	:=	rec_hz.column35;
		    tbl_rel(36)	:=	rec_hz.column36;
		    tbl_rel(37)	:=	rec_hz.column37;
		    tbl_rel(38)	:=	rec_hz.column38;
		    tbl_rel(39)	:=	rec_hz.column39;
		    tbl_rel(40)	:=	rec_hz.column40;
		    tbl_rel(41)	:=	rec_hz.column41;
		    tbl_rel(42)	:=	rec_hz.column42;
		    tbl_rel(43)	:=	rec_hz.column43;
		    tbl_rel(44)	:=	rec_hz.column44;
		    tbl_rel(45)	:=	rec_hz.column45;
		    tbl_rel(46)	:=	rec_hz.column46;
		    tbl_rel(47)	:=	rec_hz.column47;
		    tbl_rel(48)	:=	rec_hz.column48;
		    tbl_rel(49)	:=	rec_hz.column49;
		    tbl_rel(50)	:=	rec_hz.column50;
		    tbl_rel(51)	:=	rec_hz.column51;
		    tbl_rel(52)	:=	rec_hz.column52;
		    tbl_rel(53)	:=	rec_hz.column53;
		    tbl_rel(54)	:=	rec_hz.column54;
		    tbl_rel(55)	:=	rec_hz.column55;
		    tbl_rel(56)	:=	rec_hz.column56;
		    tbl_rel(57)	:=	rec_hz.column57;
		    tbl_rel(58)	:=	rec_hz.column58;
		    tbl_rel(59)	:=	rec_hz.column59;
		    tbl_rel(60)	:=	rec_hz.column60;

                  EC_DEBUG.PL(3, 'tbl_end(1): ',tbl_end(1));
                  EC_DEBUG.PL(3, 'tbl_end(2): ',tbl_end(2));
                  EC_DEBUG.PL(3, 'tbl_end(3): ',tbl_end(3));
                  EC_DEBUG.PL(3, 'tbl_end(4): ',tbl_end(4));
                  EC_DEBUG.PL(3, 'tbl_end(5): ',tbl_end(5));
                  EC_DEBUG.PL(3, 'tbl_end(6): ',tbl_end(6));
                  EC_DEBUG.PL(3, 'tbl_end(7): ',tbl_end(7));
                  EC_DEBUG.PL(3, 'tbl_end(8): ',tbl_end(8));
                  EC_DEBUG.PL(3, 'tbl_end(9): ',tbl_end(9));
                  EC_DEBUG.PL(3, 'tbl_end(10): ',tbl_end(10));
                  EC_DEBUG.PL(3, 'tbl_end(11): ',tbl_end(11));
                  EC_DEBUG.PL(3, 'tbl_end(12): ',tbl_end(12));
                  EC_DEBUG.PL(3, 'tbl_end(13): ',tbl_end(13));
                  EC_DEBUG.PL(3, 'tbl_end(14): ',tbl_end(14));
                  EC_DEBUG.PL(3, 'tbl_end(15): ',tbl_end(15));
                  EC_DEBUG.PL(3, 'tbl_end(16): ',tbl_end(16));
                  EC_DEBUG.PL(3, 'tbl_end(17): ',tbl_end(17));
                  EC_DEBUG.PL(3, 'tbl_end(18): ',tbl_end(18));
                  EC_DEBUG.PL(3, 'tbl_end(19): ',tbl_end(19));
                  EC_DEBUG.PL(3, 'tbl_end(20): ',tbl_end(20));
                  EC_DEBUG.PL(3, 'tbl_end(21): ',tbl_end(21));
                  EC_DEBUG.PL(3, 'tbl_end(22): ',tbl_end(22));
                  EC_DEBUG.PL(3, 'tbl_end(23): ',tbl_end(23));
                  EC_DEBUG.PL(3, 'tbl_end(24): ',tbl_end(24));
                  EC_DEBUG.PL(3, 'tbl_end(25): ',tbl_end(25));
                  EC_DEBUG.PL(3, 'tbl_end(26): ',tbl_end(26));
                  EC_DEBUG.PL(3, 'tbl_end(27): ',tbl_end(27));
                  EC_DEBUG.PL(3, 'tbl_end(28): ',tbl_end(28));
                  EC_DEBUG.PL(3, 'tbl_end(29): ',tbl_end(29));
                  EC_DEBUG.PL(3, 'tbl_end(30): ',tbl_end(30));
                  EC_DEBUG.PL(3, 'tbl_end(31): ',tbl_end(31));
                  EC_DEBUG.PL(3, 'tbl_end(32): ',tbl_end(32));
                  EC_DEBUG.PL(3, 'tbl_end(33): ',tbl_end(33));
                  EC_DEBUG.PL(3, 'tbl_end(34): ',tbl_end(34));
                  EC_DEBUG.PL(3, 'tbl_end(35): ',tbl_end(35));
                  EC_DEBUG.PL(3, 'tbl_end(36): ',tbl_end(36));
                  EC_DEBUG.PL(3, 'tbl_end(37): ',tbl_end(37));
                  EC_DEBUG.PL(3, 'tbl_end(38): ',tbl_end(38));
                  EC_DEBUG.PL(3, 'tbl_end(39): ',tbl_end(39));
                  EC_DEBUG.PL(3, 'tbl_end(40): ',tbl_end(40));
                  EC_DEBUG.PL(3, 'tbl_end(41): ',tbl_end(41));
                  EC_DEBUG.PL(3, 'tbl_end(42): ',tbl_end(42));
                  EC_DEBUG.PL(3, 'tbl_end(43): ',tbl_end(43));
                  EC_DEBUG.PL(3, 'tbl_end(44): ',tbl_end(44));
                  EC_DEBUG.PL(3, 'tbl_end(45): ',tbl_end(45));
                  EC_DEBUG.PL(3, 'tbl_end(46): ',tbl_end(46));
                  EC_DEBUG.PL(3, 'tbl_end(47): ',tbl_end(47));
                  EC_DEBUG.PL(3, 'tbl_end(48): ',tbl_end(48));
                  EC_DEBUG.PL(3, 'tbl_end(49): ',tbl_end(49));
                  EC_DEBUG.PL(3, 'tbl_end(50): ',tbl_end(50));
                  EC_DEBUG.PL(3, 'tbl_end(51): ',tbl_end(51));
                  EC_DEBUG.PL(3, 'tbl_end(52): ',tbl_end(52));
                  EC_DEBUG.PL(3, 'tbl_end(53): ',tbl_end(53));
                  EC_DEBUG.PL(3, 'tbl_end(54): ',tbl_end(54));
                  EC_DEBUG.PL(3, 'tbl_end(55): ',tbl_end(55));
                  EC_DEBUG.PL(3, 'tbl_end(56): ',tbl_end(56));
                  EC_DEBUG.PL(3, 'tbl_end(57): ',tbl_end(57));
                  EC_DEBUG.PL(3, 'tbl_end(58): ',tbl_end(58));
                  EC_DEBUG.PL(3, 'tbl_end(59): ',tbl_end(59));
                  EC_DEBUG.PL(3, 'tbl_end(60): ',tbl_end(60));

		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			NULL;
		      RAISE;
		  END;					-- RELEASE QUANTITY select block
		  /************************
		  **  Forecast Quantity  **
		  ************************/


		  -- Get FORECAST_QUANTITY from CHV_HORIZONTAL_SCHEDULES

                  xProgress := 'SPSO2B-10-1150';

		  BEGIN			-- FORECAST QUANTITY select block
                    xProgress := 'SPSO2B-10-1160';
		    --DBMS_OUTPUT.PUT_LINE('LN5 '||sqlcode);
		    SELECT  *
		    INTO    rec_hz
		    FROM    chv_horizontal_schedules
		    WHERE   schedule_item_id 	= rec_item.schedule_item_id
		    AND	    schedule_id		= rec_item.schedule_id
		    AND	    row_type		= 'FORECAST_QUANTITY';


                    xProgress := 'SPSO2B-10-1170';
		    -- Copy FORECAST_QUANTITY into PL/SQL table

		    tbl_for(1)	:=	rec_hz.column1;
		    tbl_for(2)	:=	rec_hz.column2;
		    tbl_for(3)	:=	rec_hz.column3;
		    tbl_for(4)	:=	rec_hz.column4;
		    tbl_for(5)	:=	rec_hz.column5;
		    tbl_for(6)	:=	rec_hz.column6;
		    tbl_for(7)	:=	rec_hz.column7;
		    tbl_for(8)	:=	rec_hz.column8;
		    tbl_for(9)	:=	rec_hz.column9;
		    tbl_for(10)	:=	rec_hz.column10;
		    tbl_for(11)	:=	rec_hz.column11;
		    tbl_for(12)	:=	rec_hz.column12;
		    tbl_for(13)	:=	rec_hz.column13;
		    tbl_for(14)	:=	rec_hz.column14;
		    tbl_for(15)	:=	rec_hz.column15;
		    tbl_for(16)	:=	rec_hz.column16;
		    tbl_for(17)	:=	rec_hz.column17;
		    tbl_for(18)	:=	rec_hz.column18;
		    tbl_for(19)	:=	rec_hz.column19;
		    tbl_for(20)	:=	rec_hz.column20;
		    tbl_for(21)	:=	rec_hz.column21;
		    tbl_for(22)	:=	rec_hz.column22;
		    tbl_for(23)	:=	rec_hz.column23;
		    tbl_for(24)	:=	rec_hz.column24;
		    tbl_for(25)	:=	rec_hz.column25;
		    tbl_for(26)	:=	rec_hz.column26;
		    tbl_for(27)	:=	rec_hz.column27;
		    tbl_for(28)	:=	rec_hz.column28;
		    tbl_for(29)	:=	rec_hz.column29;
		    tbl_for(30)	:=	rec_hz.column30;
		    tbl_for(31)	:=	rec_hz.column31;
		    tbl_for(32)	:=	rec_hz.column32;
		    tbl_for(33)	:=	rec_hz.column33;
		    tbl_for(34)	:=	rec_hz.column34;
		    tbl_for(35)	:=	rec_hz.column35;
		    tbl_for(36)	:=	rec_hz.column36;
		    tbl_for(37)	:=	rec_hz.column37;
		    tbl_for(38)	:=	rec_hz.column38;
		    tbl_for(39)	:=	rec_hz.column39;
		    tbl_for(40)	:=	rec_hz.column40;
		    tbl_for(41)	:=	rec_hz.column41;
		    tbl_for(42)	:=	rec_hz.column42;
		    tbl_for(43)	:=	rec_hz.column43;
		    tbl_for(44)	:=	rec_hz.column44;
		    tbl_for(45)	:=	rec_hz.column45;
		    tbl_for(46)	:=	rec_hz.column46;
		    tbl_for(47)	:=	rec_hz.column47;
		    tbl_for(48)	:=	rec_hz.column48;
		    tbl_for(49)	:=	rec_hz.column49;
		    tbl_for(50)	:=	rec_hz.column50;
		    tbl_for(51)	:=	rec_hz.column51;
		    tbl_for(52)	:=	rec_hz.column52;
		    tbl_for(53)	:=	rec_hz.column53;
		    tbl_for(54)	:=	rec_hz.column54;
		    tbl_for(55)	:=	rec_hz.column55;
		    tbl_for(56)	:=	rec_hz.column56;
		    tbl_for(57)	:=	rec_hz.column57;
		    tbl_for(58)	:=	rec_hz.column58;
		    tbl_for(59)	:=	rec_hz.column59;
		    tbl_for(60)	:=	rec_hz.column60;

                  EC_DEBUG.PL(3, 'tbl_for(1): ',tbl_for(1));
                  EC_DEBUG.PL(3, 'tbl_for(2): ',tbl_for(2));
                  EC_DEBUG.PL(3, 'tbl_for(3): ',tbl_for(3));
                  EC_DEBUG.PL(3, 'tbl_for(4): ',tbl_for(4));
                  EC_DEBUG.PL(3, 'tbl_for(5): ',tbl_for(5));
                  EC_DEBUG.PL(3, 'tbl_for(6): ',tbl_for(6));
                  EC_DEBUG.PL(3, 'tbl_for(7): ',tbl_for(7));
                  EC_DEBUG.PL(3, 'tbl_for(8): ',tbl_for(8));
                  EC_DEBUG.PL(3, 'tbl_for(9): ',tbl_for(9));
                  EC_DEBUG.PL(3, 'tbl_for(10): ',tbl_for(10));
                  EC_DEBUG.PL(3, 'tbl_for(11): ',tbl_for(11));
                  EC_DEBUG.PL(3, 'tbl_for(12): ',tbl_for(12));
                  EC_DEBUG.PL(3, 'tbl_for(13): ',tbl_for(13));
                  EC_DEBUG.PL(3, 'tbl_for(14): ',tbl_for(14));
                  EC_DEBUG.PL(3, 'tbl_for(15): ',tbl_for(15));
                  EC_DEBUG.PL(3, 'tbl_for(16): ',tbl_for(16));
                  EC_DEBUG.PL(3, 'tbl_for(17): ',tbl_for(17));
                  EC_DEBUG.PL(3, 'tbl_for(18): ',tbl_for(18));
                  EC_DEBUG.PL(3, 'tbl_for(19): ',tbl_for(19));
                  EC_DEBUG.PL(3, 'tbl_for(20): ',tbl_for(20));
                  EC_DEBUG.PL(3, 'tbl_for(21): ',tbl_for(21));
                  EC_DEBUG.PL(3, 'tbl_for(22): ',tbl_for(22));
                  EC_DEBUG.PL(3, 'tbl_for(23): ',tbl_for(23));
                  EC_DEBUG.PL(3, 'tbl_for(24): ',tbl_for(24));
                  EC_DEBUG.PL(3, 'tbl_for(25): ',tbl_for(25));
                  EC_DEBUG.PL(3, 'tbl_for(26): ',tbl_for(26));
                  EC_DEBUG.PL(3, 'tbl_for(27): ',tbl_for(27));
                  EC_DEBUG.PL(3, 'tbl_for(28): ',tbl_for(28));
                  EC_DEBUG.PL(3, 'tbl_for(29): ',tbl_for(29));
                  EC_DEBUG.PL(3, 'tbl_for(30): ',tbl_for(30));
                  EC_DEBUG.PL(3, 'tbl_for(31): ',tbl_for(31));
                  EC_DEBUG.PL(3, 'tbl_for(32): ',tbl_for(32));
                  EC_DEBUG.PL(3, 'tbl_for(33): ',tbl_for(33));
                  EC_DEBUG.PL(3, 'tbl_for(34): ',tbl_for(34));
                  EC_DEBUG.PL(3, 'tbl_for(35): ',tbl_for(35));
                  EC_DEBUG.PL(3, 'tbl_for(36): ',tbl_for(36));
                  EC_DEBUG.PL(3, 'tbl_for(37): ',tbl_for(37));
                  EC_DEBUG.PL(3, 'tbl_for(38): ',tbl_for(38));
                  EC_DEBUG.PL(3, 'tbl_for(39): ',tbl_for(39));
                  EC_DEBUG.PL(3, 'tbl_for(40): ',tbl_for(40));
                  EC_DEBUG.PL(3, 'tbl_for(41): ',tbl_for(41));
                  EC_DEBUG.PL(3, 'tbl_for(42): ',tbl_for(42));
                  EC_DEBUG.PL(3, 'tbl_for(43): ',tbl_for(43));
                  EC_DEBUG.PL(3, 'tbl_for(44): ',tbl_for(44));
                  EC_DEBUG.PL(3, 'tbl_for(45): ',tbl_for(45));
                  EC_DEBUG.PL(3, 'tbl_for(46): ',tbl_for(46));
                  EC_DEBUG.PL(3, 'tbl_for(47): ',tbl_for(47));
                  EC_DEBUG.PL(3, 'tbl_for(48): ',tbl_for(48));
                  EC_DEBUG.PL(3, 'tbl_for(49): ',tbl_for(49));
                  EC_DEBUG.PL(3, 'tbl_for(50): ',tbl_for(50));
                  EC_DEBUG.PL(3, 'tbl_for(51): ',tbl_for(51));
                  EC_DEBUG.PL(3, 'tbl_for(52): ',tbl_for(52));
                  EC_DEBUG.PL(3, 'tbl_for(53): ',tbl_for(53));
                  EC_DEBUG.PL(3, 'tbl_for(54): ',tbl_for(54));
                  EC_DEBUG.PL(3, 'tbl_for(55): ',tbl_for(55));
                  EC_DEBUG.PL(3, 'tbl_for(56): ',tbl_for(56));
                  EC_DEBUG.PL(3, 'tbl_for(57): ',tbl_for(57));
                  EC_DEBUG.PL(3, 'tbl_for(58): ',tbl_for(58));
                  EC_DEBUG.PL(3, 'tbl_for(59): ',tbl_for(59));
                  EC_DEBUG.PL(3, 'tbl_for(60): ',tbl_for(60));

		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			NULL;
		      RAISE;
		  END;			       -- FORECAST QUANTITY select block

		  /********************
		  ** Total Quantity  **
		  ********************/

		  -- Get TOTAL_QUANTITY from CHV_HORIZONTAL_SCHEDULES

                  xProgress := 'SPSO2B-10-1180';

		  BEGIN				-- TOTAL QUANTITY select block
                    xProgress := 'SPSO2B-10-1190';
		    --DBMS_OUTPUT.PUT_LINE('LN6 '||sqlcode);
		    SELECT  *
		    INTO    rec_hz
		    FROM    chv_horizontal_schedules
		    WHERE   schedule_item_id 	= rec_item.schedule_item_id
		    AND	    schedule_id		= rec_item.schedule_id
		    AND	    row_type		= 'TOTAL_QUANTITY';


                    xProgress := 'SPSO2B-10-1200';
		    -- Copy TOTAL_QUANTITY into PL/SQL table

		    tbl_tot(1)	:=	rec_hz.column1;
		    tbl_tot(2)	:=	rec_hz.column2;
		    tbl_tot(3)	:=	rec_hz.column3;
		    tbl_tot(4)	:=	rec_hz.column4;
		    tbl_tot(5)	:=	rec_hz.column5;
		    tbl_tot(6)	:=	rec_hz.column6;
		    tbl_tot(7)	:=	rec_hz.column7;
		    tbl_tot(8)	:=	rec_hz.column8;
		    tbl_tot(9)	:=	rec_hz.column9;
		    tbl_tot(10)	:=	rec_hz.column10;
		    tbl_tot(11)	:=	rec_hz.column11;
		    tbl_tot(12)	:=	rec_hz.column12;
		    tbl_tot(13)	:=	rec_hz.column13;
		    tbl_tot(14)	:=	rec_hz.column14;
		    tbl_tot(15)	:=	rec_hz.column15;
		    tbl_tot(16)	:=	rec_hz.column16;
		    tbl_tot(17)	:=	rec_hz.column17;
		    tbl_tot(18)	:=	rec_hz.column18;
		    tbl_tot(19)	:=	rec_hz.column19;
		    tbl_tot(20)	:=	rec_hz.column20;
		    tbl_tot(21)	:=	rec_hz.column21;
		    tbl_tot(22)	:=	rec_hz.column22;
		    tbl_tot(23)	:=	rec_hz.column23;
		    tbl_tot(24)	:=	rec_hz.column24;
		    tbl_tot(25)	:=	rec_hz.column25;
		    tbl_tot(26)	:=	rec_hz.column26;
		    tbl_tot(27)	:=	rec_hz.column27;
		    tbl_tot(28)	:=	rec_hz.column28;
		    tbl_tot(29)	:=	rec_hz.column29;
		    tbl_tot(30)	:=	rec_hz.column30;
		    tbl_tot(31)	:=	rec_hz.column31;
		    tbl_tot(32)	:=	rec_hz.column32;
		    tbl_tot(33)	:=	rec_hz.column33;
		    tbl_tot(34)	:=	rec_hz.column34;
		    tbl_tot(35)	:=	rec_hz.column35;
		    tbl_tot(36)	:=	rec_hz.column36;
		    tbl_tot(37)	:=	rec_hz.column37;
		    tbl_tot(38)	:=	rec_hz.column38;
		    tbl_tot(39)	:=	rec_hz.column39;
		    tbl_tot(40)	:=	rec_hz.column40;
		    tbl_tot(41)	:=	rec_hz.column41;
		    tbl_tot(42)	:=	rec_hz.column42;
		    tbl_tot(43)	:=	rec_hz.column43;
		    tbl_tot(44)	:=	rec_hz.column44;
		    tbl_tot(45)	:=	rec_hz.column45;
		    tbl_tot(46)	:=	rec_hz.column46;
		    tbl_tot(47)	:=	rec_hz.column47;
		    tbl_tot(48)	:=	rec_hz.column48;
		    tbl_tot(49)	:=	rec_hz.column49;
		    tbl_tot(50)	:=	rec_hz.column50;
		    tbl_tot(51)	:=	rec_hz.column51;
		    tbl_tot(52)	:=	rec_hz.column52;
		    tbl_tot(53)	:=	rec_hz.column53;
		    tbl_tot(54)	:=	rec_hz.column54;
		    tbl_tot(55)	:=	rec_hz.column55;
		    tbl_tot(56)	:=	rec_hz.column56;
		    tbl_tot(57)	:=	rec_hz.column57;
		    tbl_tot(58)	:=	rec_hz.column58;
		    tbl_tot(59)	:=	rec_hz.column59;
		    tbl_tot(60)	:=	rec_hz.column60;

                  EC_DEBUG.PL(3, 'tbl_tot(1): ',tbl_tot(1));
                  EC_DEBUG.PL(3, 'tbl_tot(2): ',tbl_tot(2));
                  EC_DEBUG.PL(3, 'tbl_tot(3): ',tbl_tot(3));
                  EC_DEBUG.PL(3, 'tbl_tot(4): ',tbl_tot(4));
                  EC_DEBUG.PL(3, 'tbl_tot(5): ',tbl_tot(5));
                  EC_DEBUG.PL(3, 'tbl_tot(6): ',tbl_tot(6));
                  EC_DEBUG.PL(3, 'tbl_tot(7): ',tbl_tot(7));
                  EC_DEBUG.PL(3, 'tbl_tot(8): ',tbl_tot(8));
                  EC_DEBUG.PL(3, 'tbl_tot(9): ',tbl_tot(9));
                  EC_DEBUG.PL(3, 'tbl_tot(10): ',tbl_tot(10));
                  EC_DEBUG.PL(3, 'tbl_tot(11): ',tbl_tot(11));
                  EC_DEBUG.PL(3, 'tbl_tot(12): ',tbl_tot(12));
                  EC_DEBUG.PL(3, 'tbl_tot(13): ',tbl_tot(13));
                  EC_DEBUG.PL(3, 'tbl_tot(14): ',tbl_tot(14));
                  EC_DEBUG.PL(3, 'tbl_tot(15): ',tbl_tot(15));
                  EC_DEBUG.PL(3, 'tbl_tot(16): ',tbl_tot(16));
                  EC_DEBUG.PL(3, 'tbl_tot(17): ',tbl_tot(17));
                  EC_DEBUG.PL(3, 'tbl_tot(18): ',tbl_tot(18));
                  EC_DEBUG.PL(3, 'tbl_tot(19): ',tbl_tot(19));
                  EC_DEBUG.PL(3, 'tbl_tot(20): ',tbl_tot(20));
                  EC_DEBUG.PL(3, 'tbl_tot(21): ',tbl_tot(21));
                  EC_DEBUG.PL(3, 'tbl_tot(22): ',tbl_tot(22));
                  EC_DEBUG.PL(3, 'tbl_tot(23): ',tbl_tot(23));
                  EC_DEBUG.PL(3, 'tbl_tot(24): ',tbl_tot(24));
                  EC_DEBUG.PL(3, 'tbl_tot(25): ',tbl_tot(25));
                  EC_DEBUG.PL(3, 'tbl_tot(26): ',tbl_tot(26));
                  EC_DEBUG.PL(3, 'tbl_tot(27): ',tbl_tot(27));
                  EC_DEBUG.PL(3, 'tbl_tot(28): ',tbl_tot(28));
                  EC_DEBUG.PL(3, 'tbl_tot(29): ',tbl_tot(29));
                  EC_DEBUG.PL(3, 'tbl_tot(30): ',tbl_tot(30));
                  EC_DEBUG.PL(3, 'tbl_tot(31): ',tbl_tot(31));
                  EC_DEBUG.PL(3, 'tbl_tot(32): ',tbl_tot(32));
                  EC_DEBUG.PL(3, 'tbl_tot(33): ',tbl_tot(33));
                  EC_DEBUG.PL(3, 'tbl_tot(34): ',tbl_tot(34));
                  EC_DEBUG.PL(3, 'tbl_tot(35): ',tbl_tot(35));
                  EC_DEBUG.PL(3, 'tbl_tot(36): ',tbl_tot(36));
                  EC_DEBUG.PL(3, 'tbl_tot(37): ',tbl_tot(37));
                  EC_DEBUG.PL(3, 'tbl_tot(38): ',tbl_tot(38));
                  EC_DEBUG.PL(3, 'tbl_tot(39): ',tbl_tot(39));
                  EC_DEBUG.PL(3, 'tbl_tot(40): ',tbl_tot(40));
                  EC_DEBUG.PL(3, 'tbl_tot(41): ',tbl_tot(41));
                  EC_DEBUG.PL(3, 'tbl_tot(42): ',tbl_tot(42));
                  EC_DEBUG.PL(3, 'tbl_tot(43): ',tbl_tot(43));
                  EC_DEBUG.PL(3, 'tbl_tot(44): ',tbl_tot(44));
                  EC_DEBUG.PL(3, 'tbl_tot(45): ',tbl_tot(45));
                  EC_DEBUG.PL(3, 'tbl_tot(46): ',tbl_tot(46));
                  EC_DEBUG.PL(3, 'tbl_tot(47): ',tbl_tot(47));
                  EC_DEBUG.PL(3, 'tbl_tot(48): ',tbl_tot(48));
                  EC_DEBUG.PL(3, 'tbl_tot(49): ',tbl_tot(49));
                  EC_DEBUG.PL(3, 'tbl_tot(50): ',tbl_tot(50));
                  EC_DEBUG.PL(3, 'tbl_tot(51): ',tbl_tot(51));
                  EC_DEBUG.PL(3, 'tbl_tot(52): ',tbl_tot(52));
                  EC_DEBUG.PL(3, 'tbl_tot(53): ',tbl_tot(53));
                  EC_DEBUG.PL(3, 'tbl_tot(54): ',tbl_tot(54));
                  EC_DEBUG.PL(3, 'tbl_tot(55): ',tbl_tot(55));
                  EC_DEBUG.PL(3, 'tbl_tot(56): ',tbl_tot(56));
                  EC_DEBUG.PL(3, 'tbl_tot(57): ',tbl_tot(57));
                  EC_DEBUG.PL(3, 'tbl_tot(58): ',tbl_tot(58));
                  EC_DEBUG.PL(3, 'tbl_tot(59): ',tbl_tot(59));
                  EC_DEBUG.PL(3, 'tbl_tot(60): ',tbl_tot(60));

		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			NULL;
		      RAISE;
		  END;					-- TOTAL QUANTITY select block

		EXCEPTION
		  WHEN OTHERS THEN
                      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
                      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                      app_exception.raise_exception;

                END;			-- end select detail block


		/**************************************************
		**  insert PAST DUE bucketed requirments detail  **
		**************************************************/

/*		BEGIN					-- PAST DUE insert block
		-- incerment detail record sequence counter

		  x_item_detail_sequence := NVL(x_item_detail_sequence,0) + 1;
                  xProgress := 'SPSO2B-10-1210';


		  --DBMS_OUTPUT.PUT_LINE('LN7 '||sqlcode);
		  INSERT INTO ECE_SPSO_ITEM_DET
		    (
	 	    COMMUNICATION_METHOD		,
		    TRANSACTION_TYPE		,

		    RUN_ID			,
		    SCHEDULE_ITEM_DETAIL_SEQUENCE	,
		    SCHEDULE_ID			,
		    SCHEDULE_ITEM_ID		,
		    DETAIL_CATEGORY		,	-- bucketed requirments
		    DETAIL_DESCRIPTOR		,	-- Past Due
		    STARTING_DATE			,
		    ENDING_DATE			,
		    FORECAST_QUANTITY		,
		    RELEASE_QUANTITY		,
		    TOTAL_QUANTITY		,
		    TRANSACTION_RECORD_ID
		    )
		  VALUES
		    (
		    p_run_id,
		    x_item_detail_sequence,
		    rec_hz.schedule_id,
		    rec_hz.schedule_item_id,
		    'REQUIREMENT',
		    tbl_desc(1),
		    TO_DATE(NVL(tbl_start(1),'1901/01/01'), 'YYYY/MM/DD'),
		    TO_DATE(tbl_end(1), 'YYYY/MM/DD'),
		    NVL(TO_NUMBER(tbl_for(1)),0),
		    NVL(TO_NUMBER(tbl_rel(1)),0),
		    NVL(TO_NUMBER(tbl_tot(1)),0),
		    ece_spso_item_det_s.nextval
		  );

		   Bug 1742567
		    p_communication_method,
		    p_transaction_type,


                 SELECT
                 ece_spso_item_det_s.currval
                 INTO
                 l_transaction_number
                 FROM
                 dual;
                 ECE_SPSO_X.populate_extension_item_det(l_transaction_number,
                                                     rec_hz.schedule_id,
                                                     rec_hz.schedule_item_id);


		EXCEPTION
		  WHEN OTHERS THEN
                      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
                      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                      app_exception.raise_exception;
                END;			-- end select detail block
*/
		/***************************************************
		**  insert ALL OTHER bucketed requirments detail  **
		***************************************************/

		BEGIN			       -- ALL OTHER buckets insert block

		  -- loop until reach NULL columns.

		  <<buckets>>
                  xProgress := 'SPSO2B-10-1220';
		  FOR i	IN  x_min_col..x_max_col LOOP
		     EXIT WHEN (tbl_desc(i) IS NULL OR
				tbl_desc(i) ='FUTURE');

		    -- incerment detail record sequence counter
		    x_item_detail_sequence := NVL(x_item_detail_sequence,0) + 1;
                  EC_DEBUG.PL(3, 'x_item_detail_sequence: ',x_item_detail_sequence);

                    xProgress := 'SPSO2B-10-1230';


		    --DBMS_OUTPUT.PUT_LINE('LN9 '||i||sqlcode);
		    INSERT INTO ECE_SPSO_ITEM_DET
		      (
/*		      COMMUNICATION_METHOD		,
		      TRANSACTION_TYPE			,
*/
		      RUN_ID				,
	 	      SCHEDULE_ITEM_DETAIL_SEQUENCE	,
		      SCHEDULE_ID			,
		      SCHEDULE_ITEM_ID			,
		      DETAIL_CATEGORY			,	-- Bucketed Requirments
		      DETAIL_DESCRIPTOR			,	-- All  other buckets
		      STARTING_DATE			,
		      ENDING_DATE			,
		      FORECAST_QUANTITY			,
		      RELEASE_QUANTITY			,
		      TOTAL_QUANTITY			,
		      TRANSACTION_RECORD_ID
	   	      )
		    VALUES
		      (
		      p_run_id,
		      x_item_detail_sequence,
		      rec_hz.schedule_id,
		      rec_hz.schedule_item_id,
		      'REQUIREMENT',
		      tbl_desc(i),
		      TO_DATE(tbl_start(i), 'YYYY/MM/DD'),
		      TO_DATE(tbl_end(i), 'YYYY/MM/DD'),
		      NVL(TO_NUMBER(tbl_for(i)),0),
		      NVL(TO_NUMBER(tbl_rel(i)),0),
		      NVL(TO_NUMBER(tbl_tot(i)),0),
		      ece_spso_item_det_s.nextval
	      	      );

	              /*Bug 1742567
  		          p_communication_method,
		          p_transaction_type,
		      */

                         SELECT
                         ECE_SPSO_ITEM_DET_S.currval
                         INTO
                         l_transaction_number
                         FROM
                        dual;
                      ECE_SPSO_X.populate_extension_item_det(l_transaction_number,
                                                 rec_hz.schedule_id,
                                                 rec_hz.schedule_item_id);

                --Bug#19032950, support GBPA + SPO document detail with SSSO transaction
                DECLARE
                  CURSOR sch_ship_det_c IS
                  SELECT CIO.ORDER_QUANTITY       ITEM_DET_SHIP_QUANTITY, --Bug 13743110 fix
                         MUM.UOM_CODE             ITEM_DET_UOM_CODE,
                         HRL.LOCATION_CODE        ITEM_DET_ST_LOC_CODE,
                         HRL.ECE_TP_LOCATION_CODE ITEM_DET_ST_LOC_CODE_EXT,
                         HRL.ADDRESS_LINE_1       ITEM_DET_ST_ADDR_1,
                         HRL.ADDRESS_LINE_2       ITEM_DET_ST_ADDR_2,
                         HRL.ADDRESS_LINE_3       ITEM_DET_ST_ADDR_3,
                         HRL.TOWN_OR_CITY         ITEM_DET_ST_CITY,
                         HRL.POSTAL_CODE          ITEM_DET_ST_POSTAL_CODE,
                         HRL.COUNTRY              ITEM_DET_ST_COUNTRY,
                         HRL.REGION_1             ITEM_DET_ST_COUNTY,
                         HRL.REGION_2             ITEM_DET_ST_STATE,
                         HRL.REGION_3             ITEM_DET_ST_REGION_3,
                         HRL.TELEPHONE_NUMBER_1   ITEM_DET_ST_PHONE,
                         POH.SEGMENT1||decode(POR.RELEASE_NUM, NULL, NULL,'-'||to_char(POR.RELEASE_NUM))    DOCUMENT_RELEASE_NUMBER,  --Bug#19032950
                         POL.LINE_NUM             DOCUMENT_LINE_NUMBER,
                         POLL.LINE_LOCATION_ID    LINE_LOCATION_ID,
			 POLL.QUANTITY_RECEIVED   QUANTITY_RECEIVED --<BUG 7562034>
                  FROM   CHV_ITEM_ORDERS CIO, PO_LINE_LOCATIONS POLL,
                         HR_LOCATIONS HRL, MTL_UNITS_OF_MEASURE MUM,
                         PO_HEADERS POH, PO_LINES POL, PO_RELEASES POR
                  WHERE  CIO.SCHEDULE_ID = rec_item.schedule_id
                  AND    CIO.SCHEDULE_ITEM_ID = rec_item.schedule_item_id
                  AND    CIO.DOCUMENT_HEADER_ID = POLL.PO_HEADER_ID
                  AND    CIO.DOCUMENT_LINE_ID = POLL.PO_LINE_ID
                  AND    CIO.DOCUMENT_SHIPMENT_ID = POLL.LINE_LOCATION_ID
                  AND    CIO.PURCHASING_UNIT_OF_MEASURE = MUM.UNIT_OF_MEASURE(+)
                  AND    HRL.LOCATION_ID(+) = POLL.SHIP_TO_LOCATION_ID
                  AND    TRUNC(NVL(POLL.PROMISED_DATE,POLL.NEED_BY_DATE)) between
                               TO_DATE(NVL(tbl_start(i),'1901/01/01'),'YYYY/MM/DD')
                              AND  TO_DATE(tbl_end(i), 'YYYY/MM/DD')
                  AND    POLL.PO_HEADER_ID = POH.PO_HEADER_ID
                  AND    POLL.PO_LINE_ID   = POL.PO_LINE_ID
                  AND    POLL.PO_RELEASE_ID = POR.PO_RELEASE_ID(+);
                  --AND    POR.PO_HEADER_ID = POH.PO_HEADER_ID;  --Bug#19032950

		  x_schedule_ship_id number := 0;

                  BEGIN
                         IF  NVL(TO_NUMBER(tbl_rel(i)),0) > 0 THEN
                          FOR rec_ship_det IN sch_ship_det_c LOOP
                             BEGIN
                              xProgress := 'SPSO2B-10-1240';
                              SELECT max(schedule_ship_id)
                              INTO   x_schedule_ship_id
                              FROM   ece_spso_ship_det
                              WHERE  schedule_id     =  rec_item.schedule_id
                              AND    schedule_item_id=  rec_item.schedule_item_id
                              AND    schedule_item_detail_sequence =  x_item_detail_sequence;
                             EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                               x_schedule_ship_id := 0;
                             END;
                              xProgress := 'SPSO2B-10-1250';
                              x_schedule_ship_id := NVL(x_schedule_ship_id,0) + 1;

	                     xProgress := 'SPSO2B-10-1260';
                              INSERT INTO ECE_SPSO_SHIP_DET
                             (
                                RUN_ID,
                                SCHEDULE_SHIP_ID,
                                SCHEDULE_ID                 ,
                                SCHEDULE_ITEM_ID ,
                                SCHEDULE_ITEM_DETAIL_SEQUENCE,
                                ITEM_DET_SHIP_QUANTITY,
                                ITEM_DET_UOM_CODE,
                                ITEM_DET_ST_LOC_CODE,
                                ITEM_DET_ST_LOC_CODE_EXT,
                                ITEM_DET_ST_ADDR_1,
                                ITEM_DET_ST_ADDR_2,
                                ITEM_DET_ST_ADDR_3,
                                ITEM_DET_ST_CITY,
                                ITEM_DET_ST_POSTAL_CODE,
                                ITEM_DET_ST_COUNTRY,
                                ITEM_DET_ST_REGION_1,
                                ITEM_DET_ST_REGION_2,
                                ITEM_DET_ST_REGION_3,
                                ITEM_DET_ST_PHONE,
                                TRANSACTION_RECORD_ID,
                                DOCUMENT_RELEASE_NUMBER,
                                DOCUMENT_LINE_NUMBER,
                                LINE_LOCATION_ID,
				QUANTITY_RECEIVED --<BUG 7562034>
                             )
                             VALUES
                             (  p_run_id,
                                x_schedule_ship_id,
                                rec_item.schedule_id,
                                rec_item.schedule_item_id,
                                x_item_detail_sequence,
                                rec_ship_det.ITEM_DET_SHIP_QUANTITY,
                                rec_ship_det.ITEM_DET_UOM_CODE,
                                rec_ship_det.ITEM_DET_ST_LOC_CODE,
                                rec_ship_det.ITEM_DET_ST_LOC_CODE_EXT,
                                rec_ship_det.ITEM_DET_ST_ADDR_1,
                                rec_ship_det.ITEM_DET_ST_ADDR_2,
                                rec_ship_det.ITEM_DET_ST_ADDR_3,
                                rec_ship_det.ITEM_DET_ST_CITY,
                                rec_ship_det.ITEM_DET_ST_POSTAL_CODE,
                                rec_ship_det.ITEM_DET_ST_COUNTRY,
                                rec_ship_det.ITEM_DET_ST_COUNTY,
                                rec_ship_det.ITEM_DET_ST_STATE,
                                rec_ship_det.ITEM_DET_ST_REGION_3,
                                rec_ship_det.ITEM_DET_ST_PHONE,
                                ece_spso_ship_det_s.nextval,
                                rec_ship_det.DOCUMENT_RELEASE_NUMBER,
                                rec_ship_det.DOCUMENT_LINE_NUMBER,
                                rec_ship_det.LINE_LOCATION_ID,
				rec_ship_det.QUANTITY_RECEIVED --<BUG 7562034>
                             );

                             xProgress := 'SPSO2B-10-1270';
                             SELECT
                             ECE_SPSO_SHIP_DET_S.currval
                             INTO
                               l_transaction_number
                             FROM
                                 dual;
                             xProgress := 'SPSO2B-10-1280';
                             ECE_SPSO_X.populate_extension_ship_det(
                                                     l_transaction_number,
                                                     rec_item.schedule_id,
                                                     rec_item.schedule_item_id,
                                                     x_item_detail_sequence);

                          END LOOP ;
                         END IF;
                   EXCEPTION
                  WHEN OTHERS THEN
                      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
                      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                      app_exception.raise_exception;
                  END;

                END LOOP buckets;

		EXCEPTION
  		  WHEN OTHERS THEN
                      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
                      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                      app_exception.raise_exception;
		END;


	      EXCEPTION
		WHEN OTHERS THEN
                      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
                      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                      app_exception.raise_exception;
              END;			-- item detail block
             END IF;
            END LOOP item;		-- item for loop
          END IF;
	  EXCEPTION
	    WHEN OTHERS THEN
                ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
                ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
                app_exception.raise_exception;
  	  END;				-- item block

        END LOOP header;		-- header for loop

   EC_DEBUG.POP('ECE_SPSO_TRANS2.populate_supplier_sched_api2');
  EXCEPTION
    WHEN OTHERS THEN
        ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress);
        ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
        app_exception.raise_exception;
  END POPULATE_SUPPLIER_SCHED_API2;	-- end of procedure

END ECE_SPSO_TRANS2;		-- end of package body

/
