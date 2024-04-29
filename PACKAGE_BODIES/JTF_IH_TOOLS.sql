--------------------------------------------------------
--  DDL for Package Body JTF_IH_TOOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_TOOLS" AS
/* $Header: JTFIHPTB.pls 120.2 2006/01/10 00:12:14 nchouras noship $ */
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_TOOLS';

-- Created by IAleshin, based on Enh#3519691
--
PROCEDURE MIGRATE_IH_WRAPUPS(p_Wrap_Up_Level VARCHAR2 ) AS
    l_Count     NUMBER;
    l_Combinations NUMBER := 0;
    l_Wrap_Up_Level VARCHAR2(2000);
    l_Wrap_Up_Id NUMBER;
    l_Sql VARCHAR2(2000);
	TYPE t_RefCur IS REF CURSOR;
	v_RetCursor t_RefCur;
    TYPE rec_bind_Params IS RECORD
    	(
    		Name VARCHAR2(30),
    		Value VARCHAR2(2000)
		);
    TYPE t_Params IS TABLE OF rec_bind_Params INDEX BY BINARY_INTEGER;
    arr_Params t_Params;
    l_Params BINARY_INTEGER := 0;
    l_Cursor BINARY_INTEGER;
    l_Res	 BINARY_INTEGER;

	l_outcome_id 	NUMBER;
	l_result_id 	NUMBER;
	l_reason_id 	NUMBER;
	l_source_code 	VARCHAR2(2000);
	l_source_code_id NUMBER;
    l_active_outcome VARCHAR2(1);
    l_active_result VARCHAR2(1);
    l_active_reason VARCHAR2(1);
    l_result_required VARCHAR2(1);
    l_reason_required VARCHAR2(1);
	l_object_id 	NUMBER;
	l_object_type 	VARCHAR2(2000);
	b_Add_Wrap 		BOOLEAN;
	b_level_change_required BOOLEAN;
	b_end_Date_required BOOLEAN;
	l_end_date_time	DATE;
	l_wrap_id		NUMBER;
	l_Check_Level	VARCHAR2(30);
	e_Error 		EXCEPTION;
	e_Skip 			EXCEPTION;
        l_active_flag VARCHAR2(1);
BEGIN
        l_active_flag := 'Y';
	l_Wrap_Up_Level := p_Wrap_Up_Level;

	l_Sql := 'SELECT distinct tbl.outcome_id, outc.active active_outcome, '||
							'outc.result_required result_required, '||
							'tbl.result_id, result.active active_result, '||
							'result.result_required reason_required, '||
							'tbl.reason_id, reason.active active_reason, '||
							'tbl.source_code, '||
							'tbl.source_code_id FROM ';

	SAVEPOINT MIGRATE_IH_WRAPUPS;

	IF p_Wrap_Up_Level = 'INTERACTION' THEN
		l_Sql := l_Sql ||'jtf_ih_interactions tbl, ';
		l_Check_Level := 'ACTIVITY';
	ELSIF p_Wrap_Up_Level = 'ACTIVITY' THEN
		l_Sql := l_Sql ||'jtf_ih_activities tbl, ';
		l_Check_Level := 'INTERACTION';
	ELSE
		RAISE e_Error;
	END IF;
	--DBMS_OUTPUT.put_line('p_Wrap_Up_Level '|| p_Wrap_Up_Level);

	l_Sql := l_Sql||'jtf_ih_outcomes_b outc, '||
					'jtf_ih_results_b result, '||
					'jtf_ih_reasons_b reason '||
					'WHERE tbl.outcome_id = outc.outcome_id AND '||
					'tbl.result_id = result.result_id(+) AND '||
					'tbl.reason_id = reason.reason_id(+) ';

					--DBMS_OUTPUT.put_line(substr(l_Sql,1,255));
					--DBMS_OUTPUT.put_line(SUBSTR(l_Sql,256,255));

	OPEN v_RetCursor FOR l_Sql;
	LOOP
	FETCH v_RetCursor INTO
		l_outcome_id,
		l_active_outcome,
		l_result_required,
		l_result_id,
		l_active_result,
		l_reason_required,
		l_reason_id,
		l_active_reason,
		l_source_code,
		l_source_code_id;

	EXIT WHEN v_RetCursor%NOTFOUND;
		IF l_outcome_id = fnd_api.g_miss_num THEN l_result_id := NULL; END IF;
		IF l_result_id = fnd_api.g_miss_num THEN l_result_id := NULL; END IF;
		IF l_reason_id = fnd_api.g_miss_num THEN l_reason_id := NULL; END IF;
		IF l_source_code = fnd_api.g_miss_char THEN l_source_code := NULL; END IF;
		IF l_source_code_id = fnd_api.g_miss_num THEN l_source_code_id := NULL; END IF;
	BEGIN
		BEGIN
			-- IF l_active_outcome IS NULL OR l_active_result IS NULL OR l_active_reason IS NULL THEN
			--
			IF l_active_outcome IS NULL OR (l_result_id IS NOT NULL AND l_active_result IS NULL)
					OR (l_reason_id IS NOT NULL AND l_active_reason IS NULL)
					OR (l_result_required = 'Y' and l_result_id is NULL)
					OR (l_reason_required = 'Y' and l_reason_id is NULL)
					OR (l_reason_id IS NOT NULL AND l_result_id IS NULL) THEN
				RAISE e_Skip;
			END IF;

			-- Check if the source code exists
			--
			l_object_type := NULL;
			l_object_id := NULL;

			IF l_source_code_id IS NOT NULL THEN
				BEGIN
				       SELECT source_code, ARC_SOURCE_CODE_FOR, SOURCE_CODE_FOR_ID
				       INTO l_source_code, l_object_type, l_object_id
                                       FROM   AMS_SOURCE_CODES
                                       WHERE  source_code_id =  l_source_code_id
                                       and    active_flag =  l_active_flag;

				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						RAISE e_Skip;
				END;
			ELSE
				BEGIN
					IF l_source_code IS NOT NULL THEN
					        SELECT source_code_id, ARC_SOURCE_CODE_FOR, SOURCE_CODE_FOR_ID
					        INTO l_source_code_id, l_object_type, l_object_id
					        FROM AMS_SOURCE_CODES
						WHERE  source_code =  l_source_code
					        AND    active_flag =  l_active_flag;

			END IF;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						RAISE e_Skip;
				END;
			END IF;
		EXCEPTION
			WHEN TOO_MANY_ROWS THEN
				--dbms_output.put_line('l_source_code = '||l_source_code||' l_object_type='||l_object_type||' l_object_id='||l_object_id);
				NULL;
		END;
		-- check if record exists and get it's current wrap_up_level
		BEGIN
			arr_Params.DELETE;
			l_Params := 0;
			l_Sql := 'SELECT wrap_id as wrap_id, wrap_up_level as wrap_up_level '||
					 'FROM jtf_ih_wrap_ups WHERE outcome_id = :outcome_id ' ;
			l_Params := l_Params + 1;
			arr_Params(l_Params).NAME := ':outcome_id';
			arr_Params(l_Params).VALUE := l_outcome_id;
			IF l_result_id IS NOT NULL THEN
				l_Sql := l_Sql || ' AND result_id = :result_id';
				l_Params := l_Params + 1;
				arr_Params(l_Params).NAME := ':result_id';
				arr_Params(l_Params).VALUE := l_result_id;
			ELSE
				l_Sql := l_Sql || ' AND result_id IS NULL ';
			END IF;

			IF l_reason_id IS NOT NULL THEN
				l_Sql := l_Sql || ' AND reason_id = :reason_id ';
				l_Params := l_Params + 1;
				arr_Params(l_Params).NAME := ':reason_id';
				arr_Params(l_Params).VALUE := l_reason_id;
			ELSE
				l_Sql := l_Sql || ' AND reason_id IS NULL ';
			END IF;

			IF l_source_code_id IS NOT NULL THEN
				l_Sql := l_Sql || ' AND source_code_id = :source_code_id ';
				l_Params := l_Params + 1;
				arr_Params(l_Params).NAME := ':source_code_id';
				arr_Params(l_Params).VALUE := l_source_code_id;
			ELSE
				l_Sql := l_Sql || ' AND source_code_id IS NULL AND source_code IS NULL ';
			END IF;
			l_Cursor := DBMS_SQL.open_cursor;
				DBMS_SQL.parse(l_Cursor, l_Sql, DBMS_SQL.native);
				DBMS_SQL.define_column(l_Cursor, 1, l_wrap_id);
				DBMS_SQL.define_column(l_Cursor, 2, l_wrap_up_level, 30);
				FOR i IN 1..arr_Params.COUNT LOOP
					DBMS_SQL.bind_variable(l_Cursor,arr_Params(i).NAME, arr_Params(i).VALUE);
				END LOOP;
				IF DBMS_SQL.execute_and_fetch(l_cursor) <> 0 THEN
					DBMS_SQL.column_value(l_Cursor, 1, l_wrap_id);
					DBMS_SQL.column_value(l_Cursor, 2, l_wrap_up_level);
				ELSE
					DBMS_SQL.close_cursor(l_cursor);
					RAISE NO_DATA_FOUND;
				END IF;
			DBMS_SQL.close_cursor(l_cursor);

			b_Add_Wrap := FALSE;
			IF l_wrap_up_level = l_Check_Level THEN
				b_level_change_required := TRUE;
			ELSE
				b_level_change_required := FALSE;
			END IF;

			IF l_active_outcome = 'N' OR (l_result_id IS NOT NULL AND l_active_result = 'N')
					OR (l_reason_id IS NOT NULL AND l_active_reason = 'N') THEN
				b_end_date_required := TRUE;
				l_end_date_time := SYSDATE;
			ELSE
				b_end_date_required := FALSE;
				l_end_date_time := NULL;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				b_Add_Wrap := TRUE;
			WHEN TOO_MANY_ROWS THEN
				b_Add_Wrap := FALSE;
		END;
		IF b_Add_Wrap THEN
		  --dbms_output.put_line('Add!!! '||l_outcome_id||' '||l_result_id||' '||nvl(l_reason_id,-1)||' '||l_source_code_id||' '||l_source_code||' '||l_object_id||' '||l_object_type||' '||p_Wrap_Up_Level);
        			INSERT INTO jtf_ih_wrap_ups (
						WRAP_ID,
						OUTCOME_ID,
						RESULT_ID,
						REASON_ID,
						OBJECT_ID,
						OBJECT_TYPE,
						SOURCE_CODE_ID,
						SOURCE_CODE,
						WRAP_UP_LEVEL,
						START_DATE,
						END_DATE,
						CREATED_BY,
						CREATION_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_DATE,
						LAST_UPDATE_LOGIN
        				)
        			VALUES (
						JTF_IH_WRAP_UPS_S1.NEXTVAL,
						l_outcome_id,
						l_result_id,
						l_reason_id,
						l_object_id,
						l_object_type,
						l_source_code_id,
						l_source_code,
						p_Wrap_Up_Level,
						SYSDATE,
						l_end_date_time,
						fnd_global.user_id,
						SYSDATE,
						fnd_global.user_id,
						SYSDATE,
						fnd_global.login_id
        				);
		ELSE
			IF b_end_Date_required OR b_level_change_required THEN
				l_Sql := 'UPDATE jtf_ih_wrap_ups SET ';
				IF b_end_Date_required THEN
					l_Sql := l_Sql || ' END_DATE = :end_date_time ';
					IF b_level_change_required THEN
						--dbms_output.put_line('BOTH! for '||l_wrap_id);
						l_Sql := l_Sql || ', WRAP_UP_LEVEL = ''BOTH'' ';
					END IF;
				ELSE
					IF b_level_change_required THEN
						--dbms_output.put_line('BOTH! for '||l_wrap_id);
						l_Sql := l_Sql || 'WRAP_UP_LEVEL = ''BOTH'' ';
					END IF;
				END IF;
				l_Sql := l_Sql || 'WHERE WRAP_ID = :wrap_id';
				--dbms_output.put_line(l_Sql);

				IF b_end_Date_required THEN
						execute IMMEDIATE l_Sql USING l_end_date_time, l_wrap_id;
				ELSE
						execute IMMEDIATE l_Sql USING l_wrap_id;
				END IF;
			END IF;
			NULL;
		END IF;
	EXCEPTION
		WHEN e_Skip THEN
			NULL;
	END;
	END LOOP;
EXCEPTION
	WHEN e_Error THEN
		ROLLBACK TO MIGRATE_IH_WRAPUPS;
	WHEN OTHERS THEN
		ROLLBACK TO MIGRATE_IH_WRAPUPS;
		raise_application_error(-20001,SQLERRM);
END MIGRATE_IH_WRAPUPS;


-- -------------------------------------------------------------------------
-- PROCEDURE: MIGRATE_WRAPUPS
--
-- DESCRIPTION:
-- This script checks and populates data from JTF_IH_OUTCOME_RESULTS table to
-- JTF_IH_WRAP_UPS (if same records weren't found there).
--
-- HISTORY:
-- 03/14/03 ialeshin  - Created sql script
-- 08/12/03 mpetrosi  - Modified changed script into package procedure
--
-- -------------------------------------------------------------------------
PROCEDURE MIGRATE_WRAPUPS AS
    nCount number;
    sDummy varchar2(2000);
    type rWrpUps is record
        (   Outcome_Id number,
            Result_Id number,
            Reason_Id number,
            Success varchar2(2),
            Object_Id number,
            Object_Type varchar2(30),
            Source_Code_Id number,
            Source_Code varchar2(30),
            wrap_up_level varchar2(30),
            wrap_id number);
    type tWrpUps is table of rWrpUps index by binary_integer;
    ttWrpUps tWrpUps;
    nCnt binary_integer;
    sReaReq varchar2(1);
    sResReq varchar2(1);
    sSql varchar2(2000);
    iCursor binary_integer;
    iRes binary_integer;
    nCampCount number;
    nSourceCodeID number;
    nObjectId number;
    vObjectType varchar2(30);
    eNoOutcomes exception;
    eNoOutcomeId exception;
    eNoResultId exception;
    eSkip exception;

    type rec_Params is record (
            name varchar2(30),
            value varchar2(30));
    type tbl_Params is table of rec_Params index by binary_integer;
        v_Params tbl_Params;
    n_CntParams number;
    l_param_name varchar2(30);
    l_param_value number;
    l_active_flag varchar2(1);

BEGIN


    savepoint jtf_ih_migrate;

    -- If JTF_IH_OUTCOMES_B is empty then raise an exception.
    select count(*) into nCount from jtf_ih_outcomes_b;
    if nCount =  0 then
        raise eNoOutcomes;
    end if;

    l_active_flag := 'Y';

    --
    -- Loop over all active outcomes non-campaign based
    nCnt := 1;
    For curOut in (select outcome_id, result_required from jtf_ih_outcomes_b where active <> 'N' or active is null ) loop
      -- add outcome only wrap-up row if no Result is required
      if curOut.result_required = 'N' or curOut.result_required is null then
        ttWrpUps(nCnt).Outcome_Id := curOut.outcome_id;
        ttWrpUps(nCnt).Result_id := null;
        ttWrpUps(nCnt).Reason_id := null;
        ttWrpUps(nCnt).object_id := null;
        ttWrpUps(nCnt).object_type := null;
        ttWrpUps(nCnt).source_code_id := null;
        ttWrpUps(nCnt).source_code := null;
        ttWrpUps(nCnt).wrap_up_level := 'BOTH';
        nCnt := nCnt + 1;
      end if;

      -- get all the valid Outcome-Result pairs where the exists
			-- in jtf_ih_results_b and is active for the outcome.
      -- loop through  the results to create more wrap-ups for this id
      for curOutRes in (select outres.result_id, res.result_required
                        from jtf_ih_outcome_results outres, jtf_ih_results_b res
                        where outres.outcome_id = curOut.outcome_id and
                        outres.result_id = res.result_id and
                        (res.active <> 'N' or res.active is null)) loop

        -- if the result does not require a reason,
				-- then add a Outcome_id, Result_id, null reason_id wrap-up.
        if (curOutRes.result_required = 'N' or
						curOutRes.result_required is null) then
          ttWrpUps(nCnt).Outcome_Id := curOut.outcome_id;
          ttWrpUps(nCnt).Result_id := curOutRes.result_id;
          ttWrpUps(nCnt).Reason_id := null;
          ttWrpUps(nCnt).object_id := null;
          ttWrpUps(nCnt).object_type := null;
          ttWrpUps(nCnt).source_code_id := null;
          ttWrpUps(nCnt).source_code := null;
          ttWrpUps(nCnt).wrap_up_level := 'BOTH';
          nCnt := nCnt + 1;
        end if;

        -- add all valid active reasons for the current outcome_id
			  -- and result_id that exist in the jtf_ih_reasons_b table
        for curResRea in (select rr.reason_id
                          from jtf_ih_result_reasons rr, jtf_ih_reasons_b rea
                          where rr.result_id = curOutRes.result_id and
                                rr.reason_id = rea.reason_id and
																( rea.active <> 'N' or rea.active is null)) loop

          ttWrpUps(nCnt).Outcome_Id := curOut.outcome_id;
          ttWrpUps(nCnt).Result_id := curOutRes.result_id;
          ttWrpUps(nCnt).Reason_id := curResRea.reason_id;
          ttWrpUps(nCnt).object_id := null;
          ttWrpUps(nCnt).object_type := null;
          ttWrpUps(nCnt).source_code_id := null;
          ttWrpUps(nCnt).source_code := null;
          ttWrpUps(nCnt).wrap_up_level := 'BOTH';
          nCnt := nCnt + 1;
        end loop; -- end Result-Reason Loop

      end loop;  -- end Outcome-Result Loop

    end loop; -- end Outcomes Loop

    -- loop over the campaign based outcomes and build wrap-ups for them
    for curOut in (select cmpOut.outcome_id, cmpOut.source_code,
													outc.result_required
                   from jtf_ih_outcomes_b outc, jtf_ih_outcomes_campaigns cmpOut
                   where outc.outcome_id = cmpOut.outcome_id
                         and (outc.active <> 'N' or outc.active is null)
									order by outc.outcome_id) loop
      begin
      -- validate the campaign values and get the source_code_id, object_id
			-- and object_type values
        begin
          SELECT count(*), source_code_id, SOURCE_CODE_FOR_ID, ARC_SOURCE_CODE_FOR
          INTO   nCampCount, nSourceCodeID, nObjectId, vObjectType
	  FROM   AMS_SOURCE_CODES
	  WHERE  source_code =  curOut.source_code
          AND    active_flag =  l_active_flag
          group by source_code_id, SOURCE_CODE_FOR_ID, ARC_SOURCE_CODE_FOR;

          -- if the campaign is not found then skip this outcome,
					-- the campaign is not valid.
            if nCampCount = 0 then
                raise eSkip;
            end if;
        exception
            when no_data_found then
                raise eSkip;
        end;

        -- add outcome only wrap-up row for the campaign
				-- if no Result is required
        if curOut.result_required = 'N' or curOut.result_required is null then
          ttWrpUps(nCnt).Outcome_Id := curOut.outcome_id;
          ttWrpUps(nCnt).Result_id := null;
          ttWrpUps(nCnt).Reason_id := null;
          ttWrpUps(nCnt).object_id := nObjectId;
          ttWrpUps(nCnt).object_type := vObjectType;
          ttWrpUps(nCnt).source_code_id := nSourceCodeID;
          ttWrpUps(nCnt).source_code := curOut.source_code;
          ttWrpUps(nCnt).wrap_up_level := 'BOTH';
          nCnt := nCnt + 1;
        end if;

        -- get all the valid Outcome-Result pairs where the exists
				-- in jtf_ih_results_b and is active for the outcome.
        -- loop through  the results to create more wrap-ups for this id
        for curOutRes in (select outr.result_id, res.result_required
                          from jtf_ih_outcome_results outr, jtf_ih_results_b res
                          where outr.outcome_id = curOut.outcome_id and
                                outr.result_id = res.result_id and
                                (res.active <> 'N' or res.active is null)) loop

          -- if the result does not require a reason,
					-- then add a Outcome_id, Result_id, null reason_id wrap-up.
          if (curOutRes.result_required = 'N' or
							curOutRes.result_required is null) then
            ttWrpUps(nCnt).Outcome_Id := curOut.outcome_id;
            ttWrpUps(nCnt).Result_id := curOutRes.result_id;
            ttWrpUps(nCnt).Reason_id := null;
            ttWrpUps(nCnt).object_id := nObjectId;
            ttWrpUps(nCnt).object_type := vObjectType;
            ttWrpUps(nCnt).source_code_id := nSourceCodeID;
            ttWrpUps(nCnt).source_code := curOut.source_code;
            ttWrpUps(nCnt).wrap_up_level := 'BOTH';
            nCnt := nCnt + 1;
          end if;

          -- add all valid active reasons for the current outcome_id and
					-- result_id that exist in the jtf_ih_reasons_b table
          for curResRea in (select rr.reason_id from jtf_ih_result_reasons rr,
                                   jtf_ih_reasons_b rea
														where rr.result_id = curOutRes.result_id and
                                  rr.reason_id = rea.reason_id and
																(rea.active <> 'N' or rea.active is null)) loop
            ttWrpUps(nCnt).Outcome_Id := curOut.outcome_id;
            ttWrpUps(nCnt).Result_id := curOutRes.result_id;
            ttWrpUps(nCnt).Reason_id := curResRea.reason_id;
            ttWrpUps(nCnt).object_id := nObjectId;
            ttWrpUps(nCnt).object_type := vObjectType;
            ttWrpUps(nCnt).source_code_id := nSourceCodeID;
            ttWrpUps(nCnt).source_code := curOut.source_code;
            ttWrpUps(nCnt).wrap_up_level := 'BOTH';
            nCnt := nCnt + 1;
          end loop; -- end Result-Reason Loop
        end loop; -- end Outcome-Result Loop
      exception
        when eSkip then
            null;
      end;
    end loop; -- end Outcomes Loop

    iCursor := dbms_sql.open_cursor;
    for i in 1..ttWrpUps.count loop
      --sSql := 'SELECT COUNT(*) FROM jtf_ih_wrap_ups WHERE outcome_id = '||ttWrpUps(i).outcome_Id||' ';
      v_Params.delete;
      sSql := 'SELECT COUNT(*) FROM jtf_ih_wrap_ups WHERE outcome_id = :outcome_id ';
        n_CntParams := 1;
        v_Params(n_CntParams).name := ':outcome_id';
        v_Params(n_CntParams).value := to_char(ttWrpUps(i).outcome_Id);

      if ttWrpUps(i).result_id is null then
        sSql := sSql || 'AND result_id IS NULL ';
      else
        -- sSql := sSql || 'AND result_id = '||ttWrpUps(i).result_Id||' ';
        sSql := sSql || 'AND result_id = :result_id ';
        n_CntParams := n_CntParams + 1;
        v_Params(n_CntParams).name := ':result_id';
        v_Params(n_CntParams).value := to_char(ttWrpUps(i).result_Id);
      end if;

      if ttWrpUps(i).reason_id is null then
        sSql := sSql || 'AND reason_id IS NULL ';
      else
        --sSql := sSql || 'AND reason_id = '||ttWrpUps(i).reason_Id||' ';
        sSql := sSql || 'AND reason_id = :reason_id ';
        n_CntParams := n_CntParams + 1;
        v_Params(n_CntParams).name := ':reason_id';
        v_Params(n_CntParams).value := to_char(ttWrpUps(i).reason_Id);

      end if;
      if ttWrpUps(i).source_code_id is null then
        sSql := sSql || 'AND source_code_id IS NULL ';
      else
       --sSql := sSql || 'AND source_code_id = '||ttWrpUps(i).source_Code_Id||' ';
       sSql := sSql || 'AND source_code_id = :source_code_id ';
        n_CntParams := n_CntParams + 1;
        v_Params(n_CntParams).name := ':source_code_id';
        v_Params(n_CntParams).value := to_char(ttWrpUps(i).source_Code_Id);
      end if;
      if ttWrpUps(i).object_id is null then
        sSql := sSql || 'AND object_id IS NULL ';
      else
        --sSql := sSql || 'AND object_id = '||ttWrpUps(i).Object_Id||' ';
        sSql := sSql || 'AND object_id = :object_id ';
        n_CntParams := n_CntParams + 1;
        v_Params(n_CntParams).name := ':object_id';
        v_Params(n_CntParams).value := to_char(ttWrpUps(i).Object_Id);
      end if;
      if ttWrpUps(i).source_code is null then
        sSql := sSql || 'AND source_code IS NULL ';
      else
        --sSql := sSql || 'AND source_code = '''||ttWrpUps(i).source_Code||''' ';
        sSql := sSql || 'AND source_code = :source_code ';
        n_CntParams := n_CntParams + 1;
        v_Params(n_CntParams).name := ':source_code';
        v_Params(n_CntParams).value := ttWrpUps(i).source_Code;
      end if;

      -- Check a JTF_IH_WRAP_UPS about record that has same
      -- outcome_id, result_id and reason_id
      --
      -- dbms_output.put_line(sSql);
      dbms_sql.parse(iCursor, sSql, dbms_sql.native);
      FOR i IN 1..v_Params.count LOOP
        --dbms_output.put_line(i||' '||v_Params(i).name||' '||v_Params(i).value);
        dbms_sql.bind_variable(iCursor,v_Params(i).name,v_Params(i).value);
      END LOOP;

      dbms_sql.define_column(iCursor,1, nCount);
      iRes := dbms_sql.execute(iCursor);
      if dbms_sql.fetch_rows(iCursor) = 0 then
        nCount := 0;
      end if;
      dbms_sql.column_value(iCursor,1,nCount);
      -- If nCount is 0 (record not found) then create new one
			-- in the JTF_IH_WRAP_UPS
      if nCount = 0 then
        begin
          if ttWrpUps(i).result_id is null and
					   ttWrpUps(i).reason_id is not null then
            raise eSkip;
          else
            INSERT INTO jtf_ih_wrap_ups ( WRAP_ID,
                                          OUTCOME_ID,
                                          RESULT_ID,
                                          REASON_ID,
                                          SOURCE_CODE_ID,
                                          SOURCE_CODE,
                                          OBJECT_ID,
                                          OBJECT_TYPE,
                                          START_DATE,
                                          WRAP_UP_LEVEL,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN
                                      ) VALUES (
                                          jtf_ih_wrap_ups_s1.nextval,
                                          ttWrpUps(i).Outcome_Id,
                                          ttWrpUps(i).Result_Id,
                                          ttWrpUps(i).Reason_Id,
                                          ttWrpUps(i).source_code_id,
                                          ttWrpUps(i).source_code,
                                          ttWrpUps(i).object_id,
                                          ttWrpUps(i).object_type,
                                          SYSDATE,
                                          ttWrpUps(i).wrap_up_level,
                                          hz_utility_pub.user_id,
                                          SYSDATE,
                                          hz_utility_pub.last_update_login,
                                          SYSDATE,
                                          hz_utility_pub.last_update_login
                                      );
         end if;
         exception
           when eSkip then
                null;
           when others then
				        FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
 						    FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
						    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        end;
      end if;
    end loop;
    dbms_sql.close_cursor(iCursor);

    -- Enh# 3519691
	UPDATE jtf_ih_outcomes_b SET active='Y' WHERE active IS NULL;
	UPDATE jtf_ih_results_b SET active='Y' WHERE active IS NULL;
	UPDATE jtf_ih_reasons_b SET active='Y' WHERE active IS NULL;
	UPDATE JTF_IH_OUTCOMES_B set RESULT_REQUIRED = 'N' WHERE RESULT_REQUIRED is NULL;
	UPDATE JTF_IH_RESULTS_B set RESULT_REQUIRED = 'N' WHERE RESULT_REQUIRED is NULL;
	COMMIT;

    JTF_IH_TOOLS.MIGRATE_IH_WRAPUPS('INTERACTION');	-- Add unique combinations based on jtf_ih_interactions table
	JTF_IH_TOOLS.MIGRATE_IH_WRAPUPS('ACTIVITY'); 	-- Add unique combinations based on jtf_ih_activities table

    commit work;
  exception
    when eNoOutcomes then
       --dbms_output.put_line('No Outcomes!');
       rollback to jtf_ih_migrate;
		   FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
			 FND_MESSAGE.SET_TOKEN('ERRORMSG',SQLERRM);
			 FND_MSG_PUB.Add;
		RETURN;
end MIGRATE_WRAPUPS;
END JTF_IH_TOOLS;

/
