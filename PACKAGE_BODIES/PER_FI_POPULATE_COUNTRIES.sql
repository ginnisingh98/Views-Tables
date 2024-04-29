--------------------------------------------------------
--  DDL for Package Body PER_FI_POPULATE_COUNTRIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FI_POPULATE_COUNTRIES" AS
/* $Header: perfipop.pkb 120.4 2008/04/04 09:32:25 rsengupt noship $ */
--
-- Purpose: to insert the countries into user table

 PROCEDURE POPULATE_COUNTRIES
      (p_errbuf			OUT nocopy	VARCHAR2
      ,p_retcode		OUT nocopy	NUMBER
      ,p_business_group_id      IN  NUMBER )
    AS
    -- Cursor for fetching territory_short_name from fnd_territories_vl.
    --
	CURSOR c_territory (p_bg NUMBER,p_table_id NUMBER) IS
	SELECT TERRITORY_CODE||' - '||territory_short_name territory_short_name
	FROM  fnd_territories_vl
	WHERE  UPPER(TERRITORY_CODE||' - '||territory_short_name) NOT IN
	(  SELECT UPPER(row_low_range_or_name)
        FROM pay_user_rows_f
        WHERE user_table_id=p_table_id
        AND business_group_id = p_bg )
        ORDER BY TERRITORY_CODE;

	CURSOR c_update_territory(p_bg NUMBER,p_table_id NUMBER) IS
	SELECT  user_row_id
	,display_sequence
	,object_version_number
	,UPPER(row_low_range_or_name)  row_low_range_or_name
	,row_high_range
	FROM pay_user_rows_f
	WHERE user_table_id=p_table_id
	AND business_group_id = p_bg
	AND UPPER(row_low_range_or_name) IN
	(SELECT UPPER(territory_short_name)
 	FROM  fnd_territories_vl );

	CURSOR c_chk_territory(p_row_low_range_or_name VARCHAR2 ) IS
	SELECT UPPER(TERRITORY_CODE||' - '||territory_short_name) territory_short_name
	FROM  fnd_territories_vl
	WHERE  UPPER(territory_short_name) = p_row_low_range_or_name ;



    -- Local variables declared.
    --
	l_region_code            FND_TERRITORIES_TL.TERRITORY_CODE%type;
	l_region_name              FND_TERRITORIES_TL.TERRITORY_SHORT_NAME%type;
	l_user_table_id            PAY_USER_TABLES.USER_TABLE_ID%type;
	l_user_column_id           PAY_USER_COLUMNS.USER_COLUMN_ID%type;
	l_row_id                   NUMBER;
	l_row_id1                  VARCHAR2(4000);
	l_user_row_id              NUMBER;
	l_user_column_instance_id  NUMBER;
	l_effective_start_date     DATE;
	l_effective_end_date       DATE;
	l_effective_date           DATE;
	l_object_version_number    NUMBER;
	l_display_sequence 	   NUMBER;
	l_row_low_range_or_name      pay_user_rows_f.ROW_LOW_RANGE_OR_NAME%TYPE;
	l_BASE_ROW_LOW_RANGE_OR_NAME pay_user_rows_f.ROW_LOW_RANGE_OR_NAME%TYPE;

   BEGIN

	-- Get the Table ID for the Table FI_REGIONAL_MEMBERSHIP
	--
	SELECT user_table_id
	INTO l_user_table_id
	FROM pay_user_tables
	WHERE user_table_name='FI_REGIONAL_MEMBERSHIP'
        AND legislation_code='FI';

       -- Get the Column ID for the Table FI_REGIONAL_MEMBERSHIP
       --
    	SELECT user_column_id
	INTO l_user_column_id
	FROM pay_user_columns
	WHERE user_column_name='REGIONAL MEMBERSHIP'
	AND legislation_code='FI';

	FOR tc_rec IN c_update_territory(p_business_group_id,l_user_table_id)
	LOOP
	l_effective_date := TO_DATE('01010001','DDMMYYYY');
	l_row_low_range_or_name :=' ';
	l_BASE_ROW_LOW_RANGE_OR_NAME :=' ';

	/*
	 ----------------------------------------------------------
	These are the parmeters to call the PAY_USER_ROW_API.UPDATE_USER_ROW
	P_VALIDATE                     BOOLEAN                 IN     DEFAULT
	P_EFFECTIVE_DATE               DATE                    IN
	P_DATETRACK_UPDATE_MODE        VARCHAR2                IN
	P_USER_ROW_ID                  NUMBER                  IN
	P_DISPLAY_SEQUENCE             NUMBER                  IN/OUT
	P_OBJECT_VERSION_NUMBER        NUMBER                  IN/OUT
	P_ROW_LOW_RANGE_OR_NAME        VARCHAR2                IN     DEFAULT
	P_BASE_ROW_LOW_RANGE_OR_NAME   VARCHAR2                IN     DEFAULT
	P_DISABLE_RANGE_OVERLAP_CHECK  BOOLEAN                 IN     DEFAULT
	P_DISABLE_UNITS_CHECK          BOOLEAN                 IN     DEFAULT
	P_ROW_HIGH_RANGE               VARCHAR2                IN     DEFAULT
	P_EFFECTIVE_START_DATE         DATE                    OUT
	P_EFFECTIVE_END_DATE           DATE                    OUT
	 -------------------------------------------------------------
	*/

	OPEN c_chk_territory(tc_rec.row_low_range_or_name);
	FETCH c_chk_territory INTO l_row_low_range_or_name ;
	CLOSE c_chk_territory;


	PAY_USER_ROW_API.UPDATE_USER_ROW
	( FALSE
	, l_effective_date
	, 'CORRECTION'
	, tc_rec.user_row_id
	, tc_rec.display_sequence
	, tc_rec.object_version_number
	, l_row_low_range_or_name
	, l_BASE_ROW_LOW_RANGE_OR_NAME
	, FALSE
	, FALSE
	, tc_rec.row_high_range
	, l_effective_start_date
	, l_effective_end_date
	 );


	END LOOP;


	SELECT max(DISPLAY_SEQUENCE)
	INTO l_display_sequence
	FROM pay_user_rows_f
	WHERE  user_table_id=l_user_table_id
	AND business_group_id = p_business_group_id;

	IF l_display_sequence IS NULL  THEN
	/*if it is for the first time make the sequence as ZERO  */
	        l_display_sequence := 0;
	END IF;

	-- Open cursor c_territory
	--
	FOR territory_rec In c_territory(p_business_group_id,l_user_table_id)
	LOOP

	--Initializing the Variables
	--
	l_row_id :=0;
	l_user_row_id :=0;
	l_user_column_instance_id := NULL;

	/*
	 ----------------------------------------------------------
	These are the parmeters to call the PAY_USER_ROW_API.CREATE_USER_ROW
	p_validate                      in     boolean  default false
	,p_effective_date                in     date
	,p_user_table_id                 in     number
	,p_row_low_range_or_name         in     varchar2
	,p_display_sequence              in out nocopy number
	,p_business_group_id             in     number   default null
	,p_legislation_code              in     varchar2 default null
	,p_disable_range_overlap_check   in     boolean  default false
	,p_disable_units_check           in     boolean  default false
	,p_row_high_range                in     varchar2 default null
	,p_user_row_id                      out nocopy number
	,p_object_version_number            out nocopy number
	,p_effective_start_date             out nocopy date
	,p_effective_end_date               out nocopy date
	,P_BASE_ROW_LOW_RANGE_OR_NAME    IN     VARCHAR2 default   -- Not included in the call (NULL by default)

	 --Please refer bug 6908057 as the argument P_BASE_ROW_LOW_RANGE_OR_NAME has been removed
	 -------------------------------------------------------------
	*/

	-- Call the Procedure pay_user_row_api.create_user_row to insert
	--rows into the Table
	--
	l_display_sequence := l_display_sequence + 1 ;
	l_effective_date := TO_DATE('01010001','DDMMYYYY');

	/* changed to named arguments w.r.t Bug 6908057 */

	PAY_USER_ROW_API.CREATE_USER_ROW
	 (p_validate                      => FALSE
	  ,p_effective_date                => l_effective_date
	  ,p_user_table_id                 => l_user_table_id
	  ,p_row_low_range_or_name         => territory_rec.territory_short_name
	  ,p_display_sequence              => l_display_sequence
	  ,p_business_group_id             => p_business_group_id
	  ,p_legislation_code              => NULL
	  ,p_disable_range_overlap_check   => FALSE
	  ,p_disable_units_check           => FALSE
	  ,p_row_high_range                => NULL
	  ,p_user_row_id                   => l_user_row_id
	  ,p_object_version_number         => l_object_version_number
	  ,p_effective_start_date          => l_effective_start_date
	  ,p_effective_end_date            => l_effective_end_date
    	  ) ;
	/*
	----------------------------------------------------------
	These are the parmeters to call the
	PAY_USER_COLUMN_INSTANCES_PKG.INSERT_ROW
	p_rowid			 in out varchar2,
	p_user_column_instance_id in out number,
	p_effective_start_date    in date,
	p_effective_end_date      in date,
	p_user_row_id             in number,
	p_user_column_id          in number,
	p_business_group_id       in number,
	p_legislation_code        in varchar2,
	p_legislation_subgroup    in varchar2,
	p_value                   in varchar2 )
	-------------------------------------------------------------
	*/

	-- Call the Procedure PAY_USER_COLUMN_INSTANCES_PKG.INSERT_ROW  to
	-- insert rows into the Table
	--
	l_row_id1:=TO_CHAR( l_row_id);

	PAY_USER_COLUMN_INSTANCES_PKG.insert_row
       ( l_row_id1
       ,l_user_column_instance_id
       ,l_effective_start_date
	   ,l_effective_end_date
       ,l_user_row_id
       ,l_user_column_id
       ,p_business_group_id
       ,NULL
       ,NULL
       ,NULL
       );

	END LOOP;
 EXCEPTION
  WHEN OTHERS THEN

	p_errbuf  := NULL;
	p_retcode := 2;
        RAISE_APPLICATION_ERROR(-20001, SQLERRM);
END POPULATE_COUNTRIES;

END PER_FI_POPULATE_COUNTRIES;

/
