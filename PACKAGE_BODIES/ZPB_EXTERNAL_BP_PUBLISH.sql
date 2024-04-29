--------------------------------------------------------
--  DDL for Package Body ZPB_EXTERNAL_BP_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_EXTERNAL_BP_PUBLISH" AS
/* $Header: zpbpbpes.plb 120.12 2007/12/04 15:40:17 mbhat noship $  */

  is_attached                 VARCHAR2(1);

  PROCEDURE CLEANUP(l_codeaw VARCHAR2, l_dataaw VARCHAR2) AS
  BEGIN
  -- dettach the required AW in approp mode
    IF (is_attached = 'Y') THEN
      --ZPB_AW.EXECUTE('aw aliaslist ' ||l_dataaw ||' unalias SHARED');
      --ZPB_AW.EXECUTE('aw detach ' || l_codeaw );
      --ZPB_AW.EXECUTE('aw detach ' || l_dataaw );

      --b4939451
      ZPB_AW.DETACH_ALL;
      is_attached := 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END CLEANUP;

  PROCEDURE START_BUSINESS_PROCESS(
    P_api_version	IN	NUMBER,
    P_init_msg_list	IN	VARCHAR2,
    P_validation_level	IN	NUMBER,
    P_bp_name		IN	VARCHAR2,
    P_ba_name		IN	VARCHAR2,
    P_horizon_start	IN	DATE DEFAULT NULL,
    P_horizon_end 	IN	DATE DEFAULT NULL,
    P_send_date		IN	DATE DEFAULT NULL,
    X_start_member	OUT	NOCOPY VARCHAR2,
    X_end_member	OUT	NOCOPY VARCHAR2,
    X_item_key          OUT     NOCOPY VARCHAR2,
    X_msg_count		OUT	NOCOPY NUMBER,
    X_msg_data		OUT	NOCOPY VARCHAR2,
    X_return_status	OUT	NOCOPY VARCHAR2
    ) AS
    l_edit_ac_id                NUMBER;
    l_published_id              NUMBER;
    l_user                      NUMBER;
    l_isValid                   BOOLEAN;
    l_start_id                  VARCHAR2(200);
    l_end_id                    VARCHAR2(200);
    l_timemems                  VARCHAR2(4000);
    l_override_user_check       VARCHAR2(10);
    l_user_exists               NUMBER;
    l_codeAW                    VARCHAR2(30);
    l_busArea                   NUMBER;
    l_owner                     NUMBER;
    l_DataAW                    VARCHAR2(30);
    errbuf                      VARCHAR2(4000);
    l_olap_call                 VARCHAR2(4000);
    l_bp_start                  VARCHAR2(200);
    l_count                     number;
    l_hs_type                   VARCHAR2(30);
    l_he_type                   VARCHAR2(30);
    l_start_lvl                 VARCHAR2(30);
    l_end_lvl                   VARCHAR2(30);
    l_valid                     VARCHAR2(2);
    l_time_fixed                VARCHAR2(50);
    l_time_relative             VARCHAR2(50);
    l_exist_start_mem           VARCHAR2(4000);
    l_exist_end_mem             VARCHAR2(4000);
    l_respID                    number;
    l_respAppID                 number;








     CURSOR c_publ_id IS SELECT analysis_cycle_id, BUSINESS_AREA_ID, owner_id
     FROM zpb_analysis_cycles a , zpb_cycle_relationships b
     WHERE a.name = p_bp_name
     AND a.analysis_cycle_id = b.published_ac_id
     and a.BUSINESS_AREA_ID in (select BUSINESS_AREA_ID
     from zPB_BUSINESS_AREAS_VL where name = p_ba_name);

    --AGB temporay change of = to be in for bug in Business Area naming. Should change back to = before release.

     CURSOR c_horzstart_type IS SELECT value FROM zpb_ac_param_values
     WHERE analysis_cycle_id = l_published_id
     AND param_id =    ( SELECT tag FROM fnd_lookup_values_vl
     WHERE LOOKUP_TYPE = 'ZPB_PARAMS'      AND lookup_code = 'CAL_HS_TYPE');

     CURSOR c_horzend_type IS SELECT value FROM zpb_ac_param_values
     WHERE analysis_cycle_id = l_published_id
     AND param_id =    ( SELECT tag FROM fnd_lookup_values_vl
     WHERE LOOKUP_TYPE = 'ZPB_PARAMS'      AND lookup_code = 'CAL_HE_TYPE');

     CURSOR c_horzstart_mem IS SELECT value FROM zpb_ac_param_values
     WHERE analysis_cycle_id = l_published_id
     AND param_id =    ( SELECT tag FROM fnd_lookup_values_vl
     WHERE LOOKUP_TYPE = 'ZPB_PARAMS' AND lookup_code = 'CAL_HS_TIME_MEMBER');

     CURSOR c_horzend_mem IS SELECT value FROM zpb_ac_param_values
     WHERE analysis_cycle_id = l_published_id
     AND param_id =    ( SELECT tag FROM fnd_lookup_values_vl
     WHERE LOOKUP_TYPE = 'ZPB_PARAMS' AND lookup_code = 'CAL_HE_TIME_MEMBER');

     CURSOR c_bp_external IS SELECT value FROM zpb_ac_param_values
      WHERE analysis_cycle_id = l_published_id
        AND param_id =
    ( SELECT tag FROM fnd_lookup_values_vl WHERE LOOKUP_TYPE = 'ZPB_PARAMS'
         AND lookup_code = 'OVERRIDE_EXTERNAL_USER_CHECK');

  begin


  -- b4594118 23Sep05 credentials of intial caller will set back to these at end of API
    l_user := fnd_global.user_id;
    l_respID  := fnd_global.RESP_ID;
    l_respAppID  := fnd_global.RESP_APPL_ID;

    l_time_fixed := 'FIXED_TIME';
    l_time_relative := 'NUMBER_OF_PERIODS';

-- VALIDATIONS

-- 1. P_ba_name is not null and valid
select count(BUSINESS_AREA_ID) into l_count
   from zPB_BUSINESS_AREAS_VL where name = p_ba_name;

IF (P_ba_name IS NULL) or (l_count = 0) then
       FND_MESSAGE.SET_NAME('ZPB', 'ZPB_API_BA_REQUIRED');
       X_MSG_data := FND_MESSAGE.GET;
       X_return_status :=  FND_API.G_RET_STS_ERROR ;
       return;
end if;


-- 2. is a valid BP name , is it published
     OPEN c_publ_id;
     FETCH c_publ_id INTO l_published_id, l_busArea, l_owner;
     CLOSE c_publ_id;
     IF (l_published_id IS NULL) THEN
       FND_MESSAGE.SET_NAME('ZPB', 'ZPB_INV_OR_UNPUB_BP');
       X_MSG_data := FND_MESSAGE.GET;
       X_return_status :=  FND_API.G_RET_STS_ERROR ;
       return;
     END IF;

-- 3. is the requestor authorised
     OPEN c_bp_external;
     FETCH c_bp_external INTO l_override_user_check;
     CLOSE c_bp_external;
     IF (l_override_user_check IS NULL) THEN
       FND_MESSAGE.SET_NAME('ZPB', 'ZPB_INV_OR_UNPUB_BP');
       X_MSG_data := FND_MESSAGE.GET;
       X_return_status :=  FND_API.G_RET_STS_ERROR ;
       return;
     END IF;

--l_override_user_check := 'Y';
     IF (l_override_user_check = 'N' ) THEN
       SELECT COUNT(*) INTO l_user_exists FROM ZPB_BP_EXTERNAL_USERS
        WHERE analysis_cycle_id = l_published_id
          AND user_id = l_user;
       IF (l_user_exists = 0) THEN
         FND_MESSAGE.SET_NAME('ZPB', 'ZPB_INV_EXTERNAL_USER');
         X_MSG_data := FND_MESSAGE.GET;
         X_return_status :=  FND_API.G_RET_STS_ERROR ;
         return;
       END IF;
     END IF;

-- 4.a horizon can be overiden only if they are of FIXED type
     OPEN c_horzstart_type;
     FETCH c_horzstart_type INTO l_hs_type;
     CLOSE c_horzstart_type;
     IF (l_hs_type = l_time_relative) THEN
  --dbms_output.put_line(' l_time_relative');
       IF ( P_horizon_start IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('ZPB', 'ZPB_CANT_OVERIDE_REL_STIME');
         X_return_status :=  FND_API.G_RET_STS_ERROR ;
         X_MSG_data := FND_MESSAGE.GET;
         return;
       END IF;
     ELSE
  --dbms_output.put_line(' l_time_fixed');
       OPEN c_horzstart_mem;
       FETCH c_horzstart_mem INTO l_exist_start_mem;
       CLOSE c_horzstart_mem;
     END IF;

-- 4.a horizon can be overiden only if they are of FIXED type
     OPEN c_horzend_type;
     FETCH c_horzend_type INTO l_he_type;
     CLOSE c_horzend_type;
     IF (l_he_type = l_time_relative) THEN
       IF (P_horizon_end IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('ZPB', 'ZPB_CANT_OVERIDE_REL_ETIME');
         X_return_status :=  FND_API.G_RET_STS_ERROR ;
         X_MSG_data := FND_MESSAGE.GET;
         return;
       END IF;
     ELSE
       OPEN c_horzend_mem;
       FETCH c_horzend_mem INTO l_exist_end_mem;
       CLOSE c_horzend_mem;
     END IF;

-- 4. has the CALENDAR_START_DATE been reached
    SELECT value into l_bp_start FROM zpb_ac_param_values
      WHERE analysis_cycle_id = l_published_id
        AND param_id =
    ( SELECT tag FROM fnd_lookup_values_vl WHERE LOOKUP_TYPE = 'ZPB_PARAMS'
         AND lookup_code = 'CALENDAR_START_DATE');

     --if start date is greater than sysdate the start date has not been reached.
     if to_date(l_bp_start, 'YYYY/MM/DD HH24:MI:SS') - SYSDATE > 0 then
         -- x_msg_data := 'The Business Process cannot be run yet because the start date has not been reached';
         FND_MESSAGE.SET_NAME('ZPB', 'ZPB_API_BEFORE_START');
         X_MSG_data := FND_MESSAGE.GET;
         X_return_status :=  FND_API.G_RET_STS_ERROR ;
         return;
     end if;
--
--


-- IF (P_horizon_start IS NOT NULL) OR (P_horizon_end IS NOT NULL) THEN
-- 3. are the start and end horizon params valid

     -- b4594118 23Sep05 flip fnd_global.user_id to BP owner for horizion validation.
     fnd_global.apps_initialize(l_owner, 0, 0);



-- attach the required AW in approp mode

-- b4939451
--     l_codeAW := zpb_aw.get_schema||'.'|| zpb_aw.get_code_aw(l_owner) ;
--     l_dataaw := zpb_aw.get_schema||'.ZPBDATA'|| l_busArea  ;

--     ZPB_AW.EXECUTE('aw attach ' ||  l_codeaw || ' ro');
--     ZPB_AW.EXECUTE('aw attach ' ||  l_dataaw || ' ro');
--     ZPB_AW.EXECUTE('aw aliaslist ' || l_dataaw || ' alias SHARED');

     ZPB_AW.INITIALIZE (P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      X_RETURN_STATUS    => x_return_status,
                      X_MSG_COUNT        => x_msg_count,
                      X_MSG_DATA         => errbuf,
                      P_BUSINESS_AREA_ID => l_busArea,
                      P_SHARED_RW        => FND_API.G_FALSE);

     is_attached := 'Y';


  --dbms_output.put_line(l_exist_start_mem);
  --IF (p_horizon_start IS NOT NULL) OR (p_horizon_end IS NOT NULL) THEN
  IF ((l_hs_type = l_time_fixed) OR (l_he_type = l_time_fixed)) THEN
    l_olap_call    := 'shw cm.gettimemem(';
    IF p_horizon_start IS NOT NULL THEN
      l_olap_call :=  l_olap_call || '''' ||to_char(p_horizon_start,'MM-DD-YYYY') || '''' ||' ' ;
    ELSE
       l_olap_call :=  l_olap_call || 'na' || ' ';
    END IF;

    IF l_exist_start_mem IS NOT NULL THEN
      l_olap_call :=  l_olap_call || ''''|| l_exist_start_mem || '''' || ' ';
    ELSE
      l_olap_call :=  l_olap_call || 'na'|| ' ';
    END IF;

    if p_horizon_end IS NOT NULL THEN
      l_olap_call    :=  l_olap_call || '''' ||to_char(p_horizon_end,'MM-DD-YYYY') || '''' ||' ' ;
    ELSE
      l_olap_call    :=  l_olap_call || 'na'  ||' ' ;
    END IF;

    IF l_exist_end_mem IS NOT NULL THEN
      l_olap_call :=  l_olap_call || ''''|| l_exist_end_mem || '''' || ' )';
    ELSE
      l_olap_call :=  l_olap_call || 'na'|| ' )';
    END IF;

--    l_olap_call    :=  l_olap_call || l_exist_start_mem || '''' ||' ' || '''' || l_exist_end_mem || ''')';

    --dbms_output.put_line(l_olap_call);
    l_timemems := zpb_aw.interp( l_olap_call );
    --dbms_output.put_line(l_timemems);

-- ex call:
-- show cm.gettimemem('1/12/1995' '1/12/2004' )
-- ex output:
--  <SMEM>24526710000000000000011000100140<SMEM><SMNAME>January 2003<SMNAME><EMEM>24530050000000000000121000100140<EMEM><EMNAME>December 2003<EMNAME><SLEVEL>140<SLEVEL><ELEVEL>140<ELEVEL>
--  tag SMEM = start member, EMEM = end member, SMNAME = start member name, EMNAME = end member name,

    l_start_id := substr(l_timemems, instr(l_timemems, '<SMEM>')+6, instr(l_timemems, '<SMEM>', -1) - instr(l_timemems, '<SMEM>') -6);
    l_end_id   := substr(l_timemems, instr(l_timemems, '<EMEM>')+6, instr(l_timemems, '<EMEM>', -1) - instr(l_timemems, '<EMEM>') -6);
    X_start_member := substr(l_timemems, instr(l_timemems, '<SMNAME>')+8, instr(l_timemems, '<SMNAME>', -1) - instr(l_timemems, '<SMNAME>') -8);
    X_end_member   := substr(l_timemems, instr(l_timemems, '<EMNAME>')+8, instr(l_timemems, '<EMNAME>', -1) - instr(l_timemems, '<EMNAME>') -8);
    l_start_lvl :=  substr(l_timemems, instr(l_timemems, '<SLEVEL>')+8, instr(l_timemems, '<SLEVEL>', -1) - instr(l_timemems, '<SLEVEL>') -8);
    l_end_lvl :=  substr(l_timemems, instr(l_timemems, '<ELEVEL>')+8, instr(l_timemems, '<ELEVEL>', -1) - instr(l_timemems, '<ELEVEL>') -8);
--dbms_output.put_line('l_start_lvl=' || l_start_lvl);
--dbms_output.put_line('l_end_lvl=' || l_end_lvl);

--dbms_output.put_line('X_start_member=' || X_start_member);
--dbms_output.put_line('X_end_member=' || X_end_member);

    IF ((p_horizon_start IS NOT NULL AND X_start_member is null) OR (p_horizon_end IS NOT NULL AND X_end_member is null)) then
       FND_MESSAGE.SET_NAME('ZPB', 'ZPB_INVALID_DATES');
       X_MSG_data := FND_MESSAGE.GET;
       X_return_status :=  FND_API.G_RET_STS_ERROR ;
       CLEANUP(l_codeaw , l_dataaw);
       return;
    END IF;



  -- AGB 20APR06 moved from below b5015702

  -- validate if the start mem is prior to end mem
  l_olap_call  := 'show &'|| 'obj(property ''ENDDATEVAR'' ''CAL_PERIODS'')(cal_periods '''||l_end_id||''') ge &'||'obj(property ''ENDDATEVAR'' ''CAL_PERIODS'')(cal_periods '''||l_start_id||''')';
  --dbms_output.put_line(' l_olap_call=' || l_olap_call);
  l_isvalid := ZPB_AW.INTERPBOOL (l_olap_call );

    IF NOT(l_isvalid) THEN
       FND_MESSAGE.SET_NAME('ZPB', 'ZPB_INVALID_DATES');
       X_MSG_data := FND_MESSAGE.GET;
       X_return_status :=  FND_API.G_RET_STS_ERROR ;
       CLEANUP(l_codeaw , l_dataaw);
       return;
    END IF;
  -- end b5015702

  END IF; -- p_horizon_start/end is not null


-- validate the BP for solve compliance, start horizon
     IF (l_hs_type = l_time_relative) THEN
       SELECT value INTO l_start_lvl FROM zpb_ac_param_values
        WHERE analysis_cycle_id = l_published_id
          AND param_id =
       ( SELECT tag FROM fnd_lookup_values_vl WHERE LOOKUP_TYPE = 'ZPB_PARAMS'
           AND lookup_code = 'CAL_HS_LEVEL');
     END IF;

--dbms_output.put_line('l_start_lvl=' || l_start_lvl);
     zpb_acval_pvt.val_solve_hrzselections(
                          p_api_version       => 1.0,
                          p_init_msg_list     => FND_API.G_TRUE,
                          p_commit            => FND_API.G_FALSE,
                          p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count ,
                          x_msg_data          => x_msg_data ,
                          p_analysis_cycle_id => l_published_id,
                          p_hrz_level         => l_start_lvl,
                          x_isvalid           => l_valid
                          );

   IF (l_valid = 'N') THEN
     FND_MESSAGE.SET_NAME('ZPB', 'ZPB_HRZSLV_LEVELS_VALID_MSG');
     X_MSG_data      := FND_MESSAGE.GET;
     X_return_status :=  FND_API.G_RET_STS_ERROR ;
     CLEANUP(l_codeaw , l_dataaw);
     return;
   END IF;

-- validate the BP for solve compliance, end horizon
     IF (l_he_type = l_time_relative) THEN
       SELECT value INTO l_end_lvl FROM zpb_ac_param_values
        WHERE analysis_cycle_id = l_published_id
          AND param_id =
       ( SELECT tag FROM fnd_lookup_values_vl WHERE LOOKUP_TYPE = 'ZPB_PARAMS'
            AND lookup_code = 'CAL_HE_LEVEL');
     END IF;

--dbms_output.put_line('l_end_lvl=' || l_end_lvl);
     zpb_acval_pvt.val_solve_hrzselections(
                          p_api_version       => 1.0,
                          p_init_msg_list     => FND_API.G_TRUE,
                          p_commit            => FND_API.G_FALSE,
                          p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count ,
                          x_msg_data          => x_msg_data ,
                          p_analysis_cycle_id => l_published_id,
                          p_hrz_level         => l_end_lvl,
                          x_isvalid           => l_valid
                          );
   IF (l_valid = 'N') THEN
     FND_MESSAGE.SET_NAME('ZPB', 'ZPB_HRZSLV_LEVELS_VALID_MSG');
     X_MSG_data      := FND_MESSAGE.GET;
     X_return_status :=  FND_API.G_RET_STS_ERROR ;
     CLEANUP(l_codeaw , l_dataaw);
     return;
   END IF;

-- dettach the required AW in approp mode

--  b4939451
--  ZPB_AW.EXECUTE('aw aliaslist ' ||l_dataaw ||' unalias SHARED');
--  ZPB_AW.EXECUTE('aw detach ' || l_codeaw );
--  ZPB_AW.EXECUTE('aw detach ' || l_dataaw );

  ZPB_AW.DETACH_ALL;
  is_attached := 'N';

-- POST VALIDATION SUCCESS
-- b4594118 23Sep05 flip fnd_global.user_id back to calling user ID for last update by audits
-- will set back to l_owner when starting WF so BP will be run under owner ID.

     fnd_global.apps_initialize(l_user, 0, 0);

     zpb_ac_ops.create_editable_copy(l_published_id, p_bp_name , l_user, l_edit_ac_id );

     zpb_ac_ops.PUBLISH_CYCLE(
             EDITABLE_AC_ID_IN     => l_edit_ac_id
            ,PUBLISHED_BY_IN       => l_owner
            ,PUBLISH_OPTIONS_IN    => 'UPDATE_FOR_FUTURE'
            ,p_bp_name_in          => p_bp_name
            ,p_external            => 'Y'
            ,p_START_MEM_IN        => l_start_id
            ,p_END_MEM_IN          => l_end_id
            ,p_send_date_in        => p_send_date
            ,PUBLISHED_AC_ID_OUT   => l_published_id
            ,X_item_key_out        => X_item_key
            );

     -- b4594118 23Sep05 reset caller credentials
     fnd_global.apps_initialize(l_user, l_respID, l_respAppID);

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     commit;
   exception
     WHEN OTHERS THEN
       CLEANUP(l_codeaw , l_dataaw);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       X_MSG_data := SUBSTR(sqlerrm, 1, 255);

   end  START_BUSINESS_PROCESS;

END ZPB_EXTERNAL_BP_PUBLISH ;

/
