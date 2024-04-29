--------------------------------------------------------
--  DDL for Package Body HZ_CUST_CLASS_DENORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_CLASS_DENORM" AS
/* $Header: ARHCLDPB.pls 120.11.12010000.2 2013/08/06 04:29:59 rgokavar ship $ */

--
-- HISTORY
-- 05/10/2002       AWU    Created
-- 06/20/2002       AWU    Changed nvl statement into two seperate statements
--                         for better performance
-- 12/23/2003   Ramesh Ch  Bug No:3335143.Removed the trace procedure and its calls.
-- 01/22/2004   Rajib R B  Bug No:3330144.Modified procedure insert_class_codes.
--                         Removed the check for ALLOW_MULTI_PARENT_FLAG='N'.
-- 01/07/2004   V.Ravichan Bug No:3735880. Modified Main() to comply with GSCC standards.
-- 07/27/2004   Rajib R B  Bug No:2657352. Modified the sequels which update
--                         selectable_flag of hz_class_code_denorm in procedure
--                         insert_class_codes.
-- 08/05/2013   Sudhir Gokavarapu  Bug No: 17253579 In rebuild_intermedia_index procedure
--                         Alter Index synchronize changed to ad_ctx_ddl.sync_index

PROCEDURE Debug_Message(
    p_msg_level IN NUMBER,
--    p_app_name IN VARCHAR2 := 'AR',
    p_msg       IN VARCHAR2)
IS
l_length    NUMBER;
l_start     NUMBER := 1;
l_substring VARCHAR2(50);
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
/*
        l_length := lengthb(p_msg);

        -- FND_MESSAGE doesn't allow message name to be over 30 chars
        -- chop message name if length > 30
        WHILE l_length > 30 LOOP
            l_substring := substrb(p_msg, l_start, 30);

            FND_MESSAGE.Set_Name('AR', l_substring);
--          FND_MESSAGE.Set_Name(p_app_name, l_substring);
            l_start := l_start + 30;
            l_length := l_length - 30;
            FND_MSG_PUB.Add;
        END LOOP;

        l_substring := substrb(p_msg, l_start);
        FND_MESSAGE.Set_Name('AR', l_substring);
--        dbms_output.put_line('l_substring: ' || l_substring);
--      FND_MESSAGE.Set_Name(p_app_name, p_msg);
        FND_MSG_PUB.Add;
*/
        l_length := lengthb(p_msg);

        -- FND_MESSAGE doesn't allow application name to be over 30 chars
        -- chop message name if length > 30
        IF l_length > 30
        THEN
            l_substring := substrb(p_msg, l_start, 30);
            FND_MESSAGE.Set_Name('AR', l_substring);
       --     FND_MESSAGE.Set_Name(l_substring, '');
        ELSE
            FND_MESSAGE.Set_Name('AR', p_msg);
       --     FND_MESSAGE.Set_Name(p_msg, '');
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Debug_Message;


PROCEDURE write_log(p_debug_source NUMBER, p_fpt number, p_mssg  varchar2) IS
BEGIN
     IF p_debug_source = G_DEBUG_CONCURRENT THEN
            -- p_fpt (1,2)?(log : output)
            FND_FILE.put(p_fpt, p_mssg);
            FND_FILE.NEW_LINE(p_fpt, 1);
            -- If p_fpt == 2 and debug flag then also write to log file
            IF p_fpt = 2 And G_Debug THEN
               FND_FILE.put(1, p_mssg);
               FND_FILE.NEW_LINE(1, 1);
            END IF;
     END IF;

    IF G_Debug AND p_debug_source = G_DEBUG_TRIGGER THEN
        -- Write debug message to message stack
            Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, p_mssg);
    END IF; -- G_Debug

    EXCEPTION
        WHEN OTHERS THEN
         NULL;
END Write_Log;
--Bug No: 17253579
--Alter Index synchronize changed to ad_ctx_ddl.sync_index
PROCEDURE rebuild_intermedia_index
is
l_bool BOOLEAN;
l_status VARCHAR2(255);
l_index_owner VARCHAR2(255);
l_tmp           VARCHAR2(2000);
  l_index       varchar2(100);
begin


    l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_index_owner);
    l_index := l_index_owner ||'.hz_class_code_denorm_t1';
    if l_bool then
          Write_Log(G_DEBUG_CONCURRENT, 1,'Intermedia index being re-built...');
          --EXECUTE IMMEDIATE 'ALTER INDEX ' || l_index_owner ||'.hz_class_code_denorm_t1 REBUILD online parameters (''sync'')';
          ad_ctx_ddl.sync_index(l_index);
		  Write_Log(G_DEBUG_CONCURRENT, 1,'Intermedia index rebuilt on column concat_class_code_meaning for table HZ_CLASS_CODE_DENORM.');
    end if;
end rebuild_intermedia_index;


procedure insert_class_codes(ERRBUF  OUT NOCOPY Varchar2,
	                      RETCODE OUT NOCOPY Varchar2,
		              p_class_category in varchar2) IS

BEGIN

    RETCODE := 0;

    if p_class_category is null
    then
	-- insert first level nodes

	INSERT  INTO HZ_CLASS_CODE_DENORM (
	CLASS_CATEGORY,
	CLASS_CODE,
	CLASS_CODE_MEANING,
	CLASS_CODE_DESCRIPTION,
	LANGUAGE,
	CONCAT_CLASS_CODE,
	CONCAT_CLASS_CODE_MEANING,
	CODE_LEVEL,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	ENABLED_FLAG,
	SELECTABLE_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	REQUEST_ID,
	PROGRAM_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE
)
SELECT
CC.CLASS_CATEGORY,
LV.LOOKUP_CODE,
LV.MEANING ,
LV.DESCRIPTION,
LT.LANGUAGE,
LV.LOOKUP_CODE,
LV.MEANING ,
1,
LV.START_DATE_ACTIVE,
LV.END_DATE_ACTIVE,
LV.ENABLED_FLAG,
'Y',
NVL(FND_GLOBAL.USER_ID,-1),
SYSDATE,
NVL(FND_GLOBAL.USER_ID,-1),
NVL(FND_GLOBAL.LOGIN_ID,-1),
SYSDATE,
FND_GLOBAL.CONC_REQUEST_ID,
FND_GLOBAL.CONC_PROGRAM_ID,
FND_GLOBAL.PROG_APPL_ID,
SYSDATE
FROM
FND_LOOKUP_TYPES_TL LT,
FND_LOOKUP_VALUES LV,
HZ_CLASS_CATEGORIES CC,
HZ_CLASS_CATEGORY_USES CCU
WHERE	LT.LOOKUP_TYPE = CC.CLASS_CATEGORY
AND     LT.VIEW_APPLICATION_ID = 222
AND     LV.VIEW_APPLICATION_ID = 222
AND 	CC.CLASS_CATEGORY = CCU.CLASS_CATEGORY
AND	 LV.LOOKUP_TYPE = LT.LOOKUP_TYPE
AND 	LT.LANGUAGE = LV.LANGUAGE
--AND 	CC.ALLOW_MULTI_PARENT_FLAG = 'N'
AND 	CCU.OWNER_TABLE='HZ_PARTIES'
AND 	NOT EXISTS(
		SELECT 'X'
		FROM HZ_CLASS_CODE_RELATIONS CCR
		WHERE LV.LOOKUP_CODE = CCR.SUB_CLASS_CODE
		AND CCR.CLASS_CATEGORY = LT.LOOKUP_TYPE
		AND sysdate between ccr.start_date_active and nvl(ccr.end_date_active,sysdate));

    --Loop insert nodes in increasing level order starting from level 2 exit when no data found
    FOR I IN 2 ..HZ_CUST_CLASS_DENORM.G_CODE_LEVEL LOOP
    BEGIN

	INSERT  INTO HZ_CLASS_CODE_DENORM (
	CLASS_CATEGORY,
	CLASS_CODE,
	CLASS_CODE_MEANING,
	CLASS_CODE_DESCRIPTION,
	LANGUAGE,
	CONCAT_CLASS_CODE,
	CONCAT_CLASS_CODE_MEANING,
	CODE_LEVEL,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	ENABLED_FLAG,
	SELECTABLE_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	REQUEST_ID,
	PROGRAM_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE
)
SELECT
CC.CLASS_CATEGORY,
CCR.SUB_CLASS_CODE,
LV.MEANING,
LV.DESCRIPTION,
LT.LANGUAGE,
DENORM.CONCAT_CLASS_CODE||NVL(CC.DELIMITER,'/')||CCR.SUB_CLASS_CODE,
DENORM.CONCAT_CLASS_CODE_MEANING||NVL(CC.DELIMITER,'/')||LV.MEANING,
i,
LV.START_DATE_ACTIVE,
LV.END_DATE_ACTIVE,
LV.ENABLED_FLAG,
'Y',
NVL(FND_GLOBAL.USER_ID,-1),
SYSDATE,
NVL(FND_GLOBAL.USER_ID,-1),
NVL(FND_GLOBAL.LOGIN_ID,-1),
SYSDATE,
FND_GLOBAL.CONC_REQUEST_ID,
FND_GLOBAL.CONC_PROGRAM_ID,
FND_GLOBAL.PROG_APPL_ID,
SYSDATE
FROM
FND_LOOKUP_TYPES_TL LT,
FND_LOOKUP_VALUES LV,
HZ_CLASS_CATEGORIES CC,
HZ_CLASS_CATEGORY_USES CCU,
HZ_CLASS_CODE_RELATIONS CCR,
HZ_CLASS_CODE_DENORM DENORM
WHERE 	LT.LOOKUP_TYPE = CC.CLASS_CATEGORY
AND     LT.VIEW_APPLICATION_ID = 222
AND     LV.VIEW_APPLICATION_ID = 222
AND 	CC.CLASS_CATEGORY = CCU.CLASS_CATEGORY
AND	DENORM.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND	CCU.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND 	LV.LOOKUP_TYPE = LT.LOOKUP_TYPE
AND 	LT.LANGUAGE = LV.LANGUAGE
AND     DENORM.LANGUAGE = LT.LANGUAGE
--AND 	CC.ALLOW_MULTI_PARENT_FLAG = 'N'
AND 	CCU.OWNER_TABLE='HZ_PARTIES'
AND 	DENORM.CLASS_CODE = CCR.CLASS_CODE
AND 	CCR.SUB_CLASS_CODE = LV.LOOKUP_CODE
AND sysdate between ccr.start_date_active and nvl(ccr.end_date_active,sysdate)
AND 	DENORM.CODE_LEVEL = i-1
UNION
SELECT
CC.CLASS_CATEGORY,
CCR.SUB_CLASS_CODE,
LV.MEANING,
LV.DESCRIPTION,
LT.LANGUAGE,
DENORM.CONCAT_CLASS_CODE||NVL(CC.DELIMITER,'/')||CCR.SUB_CLASS_CODE,
DENORM.CONCAT_CLASS_CODE_MEANING||NVL(CC.DELIMITER,'/')||LV.MEANING,
i,
LV.START_DATE_ACTIVE,
LV.END_DATE_ACTIVE,
LV.ENABLED_FLAG,
'Y',
NVL(FND_GLOBAL.USER_ID,-1),
SYSDATE,
NVL(FND_GLOBAL.USER_ID,-1),
NVL(FND_GLOBAL.LOGIN_ID,-1),
SYSDATE,
FND_GLOBAL.CONC_REQUEST_ID,
FND_GLOBAL.CONC_PROGRAM_ID,
FND_GLOBAL.PROG_APPL_ID,
SYSDATE
FROM
FND_LOOKUP_TYPES_TL LT,
FND_LOOKUP_VALUES LV,
HZ_CLASS_CATEGORIES CC,
HZ_CLASS_CATEGORY_USES CCU,
HZ_CLASS_CODE_RELATIONS CCR,
HZ_CLASS_CODE_DENORM DENORM
WHERE 	LT.LOOKUP_TYPE = CC.CLASS_CATEGORY
AND     LT.VIEW_APPLICATION_ID = 222
AND     LV.VIEW_APPLICATION_ID = 222
AND 	CC.CLASS_CATEGORY = CCU.CLASS_CATEGORY
AND	DENORM.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND	CCU.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND 	LV.LOOKUP_TYPE = LT.LOOKUP_TYPE
AND 	LT.LANGUAGE = LV.LANGUAGE
AND     DENORM.LANGUAGE = LT.LANGUAGE
--AND 	CC.ALLOW_MULTI_PARENT_FLAG = 'N'
AND 	CCU.OWNER_TABLE='HZ_PARTIES'
AND 	DENORM.CLASS_CODE = CCR.CLASS_CODE
AND 	CCR.SUB_CLASS_CODE = LV.LOOKUP_CODE
AND sysdate between ccr.start_date_active and nvl(ccr.end_date_active,sysdate)
AND 	DENORM.CODE_LEVEL = i -1;


	EXCEPTION
		WHEN NO_DATA_FOUND THEN EXIT;
	END;
      END LOOP;


	-- set selectable_flag based on allow_leaf_node_only_flag

     /* Bug 2657352. Removed hz_class_code_relations rel1 and fnd_lookup_values lv from the join.
      *              Furthermore considered the date range of the relationships in
      *              hz_class_code_relations
      *
      *	update hz_class_code_denorm denorm
      *	set selectable_flag ='N'
      *	where exists (select 'x'
      *		      from  hz_class_code_relations rel1,
      *				 hz_class_code_relations rel2,
      *				  fnd_lookup_values lv,
      *				 hz_class_categories cc
      *				where lv.lookup_type = denorm.class_category
      *				 and lv.VIEW_APPLICATION_ID = 222
      *				 and denorm.class_category= rel1.class_category
      *				 and denorm.class_category= rel2.class_category
      *				 and cc.class_category = denorm.class_category
      *				 and  (rel1.sub_class_code = denorm.class_code
      *				 or lv.lookup_code = rel1.sub_class_code)
      *				 and rel2.class_code = denorm.class_code
      *				 and cc.allow_leaf_node_only_flag = 'Y');
      */

      	UPDATE hz_class_code_denorm denorm
      	SET    selectable_flag ='N'
      	WHERE EXISTS
	      (SELECT 'X'
      	       FROM   hz_class_code_relations rel1,
                      hz_class_categories cc
      	       WHERE  denorm.class_category =  rel1.class_category    AND
      		      cc.class_category     =  denorm.class_category  AND
      	              rel1.class_code       =  denorm.class_code      AND
		      SYSDATE               >= rel1.start_date_active AND
		      SYSDATE               <= NVL( rel1.end_date_active , SYSDATE + 1) AND
      		      cc.allow_leaf_node_only_flag = 'Y');


	-- Set frozen_flag to 'Y' - means no dirty data
	update hz_class_categories
        set frozen_flag = 'Y'
        where (frozen_flag = 'N' or frozen_flag is null);

    else   -- p_class_category is passed in

	-- insert first level nodes

	INSERT  INTO HZ_CLASS_CODE_DENORM (
	CLASS_CATEGORY,
	CLASS_CODE,
	CLASS_CODE_MEANING,
	CLASS_CODE_DESCRIPTION,
	LANGUAGE,
	CONCAT_CLASS_CODE,
	CONCAT_CLASS_CODE_MEANING,
	CODE_LEVEL,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	ENABLED_FLAG,
	SELECTABLE_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	REQUEST_ID,
	PROGRAM_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE
)
SELECT
CC.CLASS_CATEGORY,
LV.LOOKUP_CODE,
LV.MEANING ,
LV.DESCRIPTION,
LT.LANGUAGE,
LV.LOOKUP_CODE,
LV.MEANING ,
1,
LV.START_DATE_ACTIVE,
LV.END_DATE_ACTIVE,
LV.ENABLED_FLAG,
'Y',
NVL(FND_GLOBAL.USER_ID,-1),
SYSDATE,
NVL(FND_GLOBAL.USER_ID,-1),
NVL(FND_GLOBAL.LOGIN_ID,-1),
SYSDATE,
FND_GLOBAL.CONC_REQUEST_ID,
FND_GLOBAL.CONC_PROGRAM_ID,
FND_GLOBAL.PROG_APPL_ID,
SYSDATE
FROM
FND_LOOKUP_TYPES_TL LT,
FND_LOOKUP_VALUES LV,
HZ_CLASS_CATEGORIES CC,
HZ_CLASS_CATEGORY_USES CCU
WHERE	LT.LOOKUP_TYPE = CC.CLASS_CATEGORY
AND     LT.VIEW_APPLICATION_ID = 222
AND     LV.VIEW_APPLICATION_ID = 222
AND 	CC.CLASS_CATEGORY = CCU.CLASS_CATEGORY
AND	 LV.LOOKUP_TYPE = LT.LOOKUP_TYPE
AND 	LT.LANGUAGE = LV.LANGUAGE
--AND 	CC.ALLOW_MULTI_PARENT_FLAG = 'N'
AND 	CCU.OWNER_TABLE='HZ_PARTIES'
AND CC.CLASS_CATEGORY = P_CLASS_CATEGORY
AND 	NOT EXISTS(
		SELECT 'X'
		FROM HZ_CLASS_CODE_RELATIONS CCR
		WHERE LV.LOOKUP_CODE = CCR.SUB_CLASS_CODE
		AND CCR.CLASS_CATEGORY = LT.LOOKUP_TYPE
		AND sysdate between ccr.start_date_active and nvl(ccr.end_date_active,sysdate));


    --Loop insert nodes in increasing level order starting from level 2 exit when no data found
    FOR I IN 2 ..HZ_CUST_CLASS_DENORM.G_CODE_LEVEL LOOP
    BEGIN

	INSERT  INTO HZ_CLASS_CODE_DENORM (
	CLASS_CATEGORY,
	CLASS_CODE,
	CLASS_CODE_MEANING,
	CLASS_CODE_DESCRIPTION,
	LANGUAGE,
	CONCAT_CLASS_CODE,
	CONCAT_CLASS_CODE_MEANING,
	CODE_LEVEL,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	ENABLED_FLAG,
	SELECTABLE_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	REQUEST_ID,
	PROGRAM_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE
)
SELECT
CC.CLASS_CATEGORY,
CCR.SUB_CLASS_CODE,
LV.MEANING,
LV.DESCRIPTION,
LT.LANGUAGE,
DENORM.CONCAT_CLASS_CODE||NVL(CC.DELIMITER,'/')||CCR.SUB_CLASS_CODE,
DENORM.CONCAT_CLASS_CODE_MEANING||NVL(CC.DELIMITER,'/')||LV.MEANING,
i,
LV.START_DATE_ACTIVE,
LV.END_DATE_ACTIVE,
LV.ENABLED_FLAG,
'Y',
NVL(FND_GLOBAL.USER_ID,-1),
SYSDATE,
NVL(FND_GLOBAL.USER_ID,-1),
NVL(FND_GLOBAL.LOGIN_ID,-1),
SYSDATE,
FND_GLOBAL.CONC_REQUEST_ID,
FND_GLOBAL.CONC_PROGRAM_ID,
FND_GLOBAL.PROG_APPL_ID,
SYSDATE
FROM
FND_LOOKUP_TYPES_TL LT,
FND_LOOKUP_VALUES LV,
HZ_CLASS_CATEGORIES CC,
HZ_CLASS_CATEGORY_USES CCU,
HZ_CLASS_CODE_RELATIONS CCR,
HZ_CLASS_CODE_DENORM DENORM
WHERE 	LT.LOOKUP_TYPE = CC.CLASS_CATEGORY
AND     LT.VIEW_APPLICATION_ID = 222
AND     LV.VIEW_APPLICATION_ID = 222
AND 	CC.CLASS_CATEGORY = CCU.CLASS_CATEGORY
AND	DENORM.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND	CCU.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND 	LV.LOOKUP_TYPE = LT.LOOKUP_TYPE
AND 	LT.LANGUAGE = LV.LANGUAGE
AND     DENORM.LANGUAGE = LT.LANGUAGE
--AND 	CC.ALLOW_MULTI_PARENT_FLAG = 'N'
AND 	CCU.OWNER_TABLE='HZ_PARTIES'
AND 	DENORM.CLASS_CODE = CCR.CLASS_CODE
AND 	CCR.SUB_CLASS_CODE = LV.LOOKUP_CODE
AND CC.CLASS_CATEGORY = P_CLASS_CATEGORY
AND sysdate between ccr.start_date_active and nvl(ccr.end_date_active,sysdate)
AND 	DENORM.CODE_LEVEL = i-1
UNION
SELECT
CC.CLASS_CATEGORY,
CCR.SUB_CLASS_CODE,
LV.MEANING,
LV.DESCRIPTION,
LT.LANGUAGE,
DENORM.CONCAT_CLASS_CODE||NVL(CC.DELIMITER,'/')||CCR.SUB_CLASS_CODE,
DENORM.CONCAT_CLASS_CODE_MEANING||NVL(CC.DELIMITER,'/')||LV.MEANING,
i,
LV.START_DATE_ACTIVE,
LV.END_DATE_ACTIVE,
LV.ENABLED_FLAG,
'Y',
NVL(FND_GLOBAL.USER_ID,-1),
SYSDATE,
NVL(FND_GLOBAL.USER_ID,-1),
NVL(FND_GLOBAL.LOGIN_ID,-1),
SYSDATE,
FND_GLOBAL.CONC_REQUEST_ID,
FND_GLOBAL.CONC_PROGRAM_ID,
FND_GLOBAL.PROG_APPL_ID,
SYSDATE
FROM
FND_LOOKUP_TYPES_TL LT,
FND_LOOKUP_VALUES LV,
HZ_CLASS_CATEGORIES CC,
HZ_CLASS_CATEGORY_USES CCU,
HZ_CLASS_CODE_RELATIONS CCR,
HZ_CLASS_CODE_DENORM DENORM
WHERE 	LT.LOOKUP_TYPE = CC.CLASS_CATEGORY
AND     LT.VIEW_APPLICATION_ID = 222
AND     LV.VIEW_APPLICATION_ID = 222
AND 	CC.CLASS_CATEGORY = CCU.CLASS_CATEGORY
AND	DENORM.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND	CCU.CLASS_CATEGORY = CCR.CLASS_CATEGORY
AND 	LV.LOOKUP_TYPE = LT.LOOKUP_TYPE
AND 	LT.LANGUAGE = LV.LANGUAGE
AND     DENORM.LANGUAGE = LT.LANGUAGE
--AND 	CC.ALLOW_MULTI_PARENT_FLAG = 'N'
AND 	CCU.OWNER_TABLE='HZ_PARTIES'
AND 	DENORM.CLASS_CODE = CCR.CLASS_CODE
AND 	CCR.SUB_CLASS_CODE = LV.LOOKUP_CODE
AND CC.CLASS_CATEGORY = P_CLASS_CATEGORY
AND sysdate between ccr.start_date_active and nvl(ccr.end_date_active,sysdate)
AND 	DENORM.CODE_LEVEL = i -1;



	EXCEPTION
		WHEN NO_DATA_FOUND THEN EXIT;
	END;
      END LOOP;


	-- set selectable_flag based on allow_leaf_node_only_flag

    /* Bug 2657352.Removed joins to hz_class_code_relations rel1, fnd_lookup_values lv,
     *             hz_class_categories.
     *             Considered date range in hz_class_code_relations
     *             Performed the update only if allow_leaf_node_flag is 'Y'.
     *             Used an anonymous block so that resources for variable
     *             l_allow_leaf_node_only_flag are released after this block.
     *
     *	update hz_class_code_denorm denorm
     *	set selectable_flag ='N'
     *	where denorm.class_category = p_class_category
     *	and   exists (select 'x'
     *		      from  hz_class_code_relations rel1,
     *				 hz_class_code_relations rel2,
     *				  fnd_lookup_values lv,
     *				 hz_class_categories cc
     *				where lv.lookup_type = denorm.class_category
     *				 and lv.VIEW_APPLICATION_ID = 222
     *				 and denorm.class_category= rel1.class_category
     *				 and denorm.class_category= rel2.class_category
     *				 and cc.class_category = denorm.class_category
     *				 AND CC.CLASS_CATEGORY = P_CLASS_CATEGORY
     *				 and  (rel1.sub_class_code = denorm.class_code
     *				 or lv.lookup_code = rel1.sub_class_code)
     *				 and rel2.class_code = denorm.class_code
     *				 and cc.allow_leaf_node_only_flag = 'Y');
     */

     DECLARE
         l_allow_leaf_node_only_flag HZ_CLASS_CATEGORIES.ALLOW_LEAF_NODE_ONLY_FLAG%TYPE;
     BEGIN
         SELECT allow_leaf_node_only_flag
         INTO   l_allow_leaf_node_only_flag
         FROM   HZ_CLASS_CATEGORIES
         WHERE  class_category = p_class_category;

         IF (l_allow_leaf_node_only_flag = 'Y')
         THEN
             -- set selectable_flag based on allow_leaf_node_only_flag
             UPDATE hz_class_code_denorm denorm
             SET    selectable_flag ='N'
             WHERE  denorm.class_category = p_class_category AND
	            EXISTS
		        (SELECT 'x'
		         FROM   hz_class_code_relations rel1
			 WHERE  denorm.class_category = rel1.class_category AND
				rel1.class_code = denorm.class_code AND
				SYSDATE >= rel1.start_date_active AND
				SYSDATE <= NVL(rel1.end_date_active, SYSDATE + 1)
       		        );
         END IF;
     END;

	-- Set frozen_flag to 'Y' - means no dirty data
	update hz_class_categories
        set frozen_flag = 'Y'
        where class_category = p_class_category
        and (frozen_flag = 'N' or frozen_flag is null);

 end if;

     IF (RETCODE = 0) THEN
	 COMMIT;
	 rebuild_intermedia_index;
     END IF;

     EXCEPTION WHEN OTHERS THEN
	ERRBUF := ERRBUF||sqlerrm;
	RETCODE := '1';
	--Write_Log(G_DEBUG_CONCURRENT, 1, 'Error in insert_class_codes: '||SQLCODE);
	--Write_Log(G_DEBUG_CONCURRENT, 1,substrb(sqlerrm,1,700));

END insert_class_codes;


Procedure Main(ERRBUF       OUT NOCOPY Varchar2,
    RETCODE      OUT NOCOPY Varchar2,
    p_class_category IN Varchar2,
    p_debug_mode IN  Varchar2,
    p_trace_mode IN  Varchar2) is

l_count number:=0;
l_status Boolean;
l_table_name varchar2(30);
-- Code added for Bug 3735880 starts here
l_bool BOOLEAN;
l_status_owner VARCHAR2(255);
l_table_owner VARCHAR2(255);
l_tmp           VARCHAR2(2000);
-- Code added for Bug 3735880 ends here
begin
        -- start of savepoint
        SAVEPOINT main;
	IF p_debug_mode = 'Y' THEN G_Debug := TRUE; ELSE G_Debug := FALSE; END IF;

	Write_Log(G_DEBUG_CONCURRENT, 1, 'Process began @: ' || to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

	RETCODE     := 0;

        if p_class_category is null
	then
		-- full refresh
-- Code added for Bug 3735880 starts here
                l_bool := fnd_installation.GET_APP_INFO('AR',l_status_owner,l_tmp,l_table_owner);
                if l_bool then
		EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_table_owner||'.HZ_CLASS_CODE_DENORM REUSE STORAGE';
                end if;
-- Code added for Bug 3735880 ends here
	else
		-- only refresh passing in class_category
		delete from hz_class_code_denorm where class_category = p_class_category;
	end if;

	IF (RETCODE = 0) THEN
          insert_class_codes(ERRBUF, RETCODE, p_class_category);
          COMMIT;
	END IF;

	IF (nvl(RETCODE,0) <> 0) THEN
	        l_status := fnd_concurrent.set_completion_status('ERROR',ERRBUF);
	        IF l_status = TRUE THEN
			Write_Log(G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program');
		END IF;
	END IF;

	Write_Log(G_DEBUG_CONCURRENT, 1, 'Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));
	EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ERRBUF := ERRBUF||'Error in HZ_CUST_CLASS_DENORM.Main:'||to_char(sqlcode)||sqlerrm;
                RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
                Write_Log(G_DEBUG_CONCURRENT, 1,'Error in HZ_CUST_CLASS_DENORM.Main');
                Write_Log(G_DEBUG_CONCURRENT, 1,sqlerrm);
                ROLLBACK to main;
                l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
                IF l_status = TRUE THEN
                        Write_Log(G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
                END IF;
        WHEN OTHERS THEN
                ERRBUF := ERRBUF||'Error in HZ_CUST_CLASS_DENORM.Main:'||to_char(sqlcode)||sqlerrm;
                RETCODE := '2';
                Write_Log(G_DEBUG_CONCURRENT, 1,'Error in HZ_CUST_CLASS_DENORM.Main');
                Write_Log(G_DEBUG_CONCURRENT, 1,sqlerrm);
		 ROLLBACK to main;
                l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
                IF l_status = TRUE THEN
                        Write_Log(G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
                END IF;

end Main;


End HZ_CUST_CLASS_DENORM;

/
