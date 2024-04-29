--------------------------------------------------------
--  DDL for Package Body WF_MAILER_PARAMETER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_MAILER_PARAMETER" as
/* $Header: wfmlrpb.pls 120.10 2007/11/16 05:43:16 dgadhira ship $ */
--------------------------------------------------------------------------
/*
** PRIVATE global variables
*/
default_name varchar2(15) := '-WF_DEFAULT-';
valid_param VARCHAR2(6) := 'VALID';
no_validation VARCHAR2(6) := '-NONE-';

--------------------------------------------------------------------------
   -- GetValue - To return a parameter value
   -- IN
   -- The name for the mailer instance
   -- The name of the parameter
   -- RETURNS
   -- the value of the node/parameter combination. If this
   -- does not exist, then the -WF_DEFAULT-/parameter combination
   FUNCTION GetValue(pName IN VARCHAR2, pParam IN VARCHAR2) RETURN VARCHAR2
   IS
      lValue varchar2(200);
   BEGIN
      begin
         select VALUE
         into lValue
         from WF_MAILER_PARAMETERS
         where NAME = pName
           and PARAMETER = pParam;
      exception
         when no_data_found then
            select VALUE
            into lValue
            from WF_MAILER_PARAMETERS wp
            where NAME = DEFAULT_NAME
              and parameter = pParam;
         when others then raise;
      end;
      return lValue;
   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'GetValue', pName, pParam);
         raise;
   END GetValue;

   -- GetValue - To return a parameter value where the parameter
   --            value can be overridden by a message attribute.
   -- IN
   -- Notification ID
   -- The name for the mailer instance
   -- The name of the parameter
   -- RETURNS
   -- the value of the node/parameter combination. If this
   -- does not exist, then the -WF_DEFAULT-/parameter combination
   -- Where the value is in extended notation, then the NID is checked
   -- for the availablity of the message attribute.
   FUNCTION GetValue(pNID IN NUMBER, pName IN VARCHAR2, pParam IN VARCHAR2)
            RETURN VARCHAR2
   IS
      lValue VARCHAR2(200);
      quot pls_integer;
      i pls_integer;
      c varchar2(1);
      attr varchar2(2000);
      defv varchar2(2000);

      TYPE stack_t IS TABLE OF
           varchar2(2000) INDEX BY BINARY_INTEGER;
      stack stack_t;
      buf varchar2(2000);

   BEGIN
      lValue := GetValue(pName, pParam);

      -- Parse the lValue for the "token":"token" structure.
      -- The idea here is that we push a token to the stack each
      -- time we encounter a quote. The \ character is an escape.
      if lValue is not null or lValue <> '' then
         quot := 1;
         i := 1;
         buf := '';
         while i <= length(lValue) loop
            c := substrb(lValue, i, 1);
            if c = '"' then
               if buf is not null or buf <> '' then
                  -- Push the buffer to the stack and start again
                  stack(quot) := buf;
                  quot := quot + 1;
                  buf := '';
               end if;
            elsif c = '\' then
               -- Escape character. Consume this and the next
               -- character.
               i := i + 1;
               c := substrb(lValue, i, 1);
               buf := buf ||c;
            else
               buf := buf || c;
            end if;
            i := i + 1;
         end loop;
         if buf is not null or buf <> '' then
            stack(quot) := buf;
         end if;

         IF stack.count = 3 AND instrb(trim(stack(2)),':',1)>0 THEN
            -- The format conforms to the extended notation
            -- Obtain the message attribute and confirm the value.
            attr := stack(1);
            defv := stack(3);
            IF substrb(attr, 1, 1)='&' THEN
               BEGIN
                  lValue := wf_notification.getAttrText(pNID, substrb(attr,2));
               EXCEPTION
                  WHEN OTHERS THEN
                     wf_core.clear;
                     lValue := defv;
               END;
            ELSE
               lValue := attr;
            END IF;
         ELSIF stack.count = 1 THEN
            -- Only one element was found. Use this.
            lValue := stack(1);
         ELSE
            -- There was a syntax error in the string. ie it did not
            -- resolve to three or one tokens where token 2 is a ":".
            wf_core.token('NID', to_char(pNID));
            wf_core.token('NAME', pName);
            wf_core.token('PARAM', pParam);
            wf_core.token('VALUE',lValue);
            wf_core.raise('WFMLR_PARAMETER_SYNTAX');
         END IF;
      END IF;
      return lValue;
   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'GetValue', to_char(pNID),
                         pName, pParam);
         raise;
   END GetValue;

   -- GetValues - To return a PL/SQL table of parameters
   -- IN
   -- The name for the mailer instance
   -- OUT
   -- PL/SQL table of the parameters for the speicified mailer name.
   PROCEDURE GetValues(pName IN VARCHAR2,
                       pParams IN OUT NOCOPY wf_mailer_params_tbl_type)
   IS
      CURSOR c IS
      SELECT name, parameter, value, required
        FROM wf_mailer_parameters
       WHERE name = pName
       UNION
      SELECT pName name, parameter, value, required
        FROM wf_mailer_parameters
       WHERE name = '-WF_DEFAULT-'
         AND parameter NOT IN (SELECT parameter
                          FROM wf_mailer_parameters
                          WHERE name = pName);

      i PLS_INTEGER;

   BEGIN
      pParams.DELETE;
      i := 1;
      FOR r IN c LOOP
         pParams(i).Name := r.Name;
         pParams(i).Parameter := r.Parameter;
         pParams(i).Value := r.Value;
         i := i + 1;
      END LOOP;

   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'GetValues', pName);
         raise;
   END GetValues;

   -- PRIVATE
   -- PutParameter - To insert a new parameter. For use by the
   --                loader.
   PROCEDURE PutParameter(pName IN VARCHAR2, pParameter IN VARCHAR2,
                          pValue IN VARCHAR2, pRequired IN VARCHAR2,
                          pCB IN VARCHAR2, pAllowReload IN VARCHAR2)
   IS
      lexists INTEGER;
   BEGIN
     lexists := 0;
     BEGIN
        SELECT COUNT(*)
        INTO lexists
        FROM wf_mailer_parameters
        WHERE name = pName
          AND parameter = pParameter;
        UPDATE wf_mailer_parameters
        SET value = pValue,
            required = pRequired,
            cb = pCB,
            allow_reload = pAllowReload
        WHERE name = pName
          AND parameter = pParameter;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lexists := 0;
     END;
     IF lexists = 0 THEN
        INSERT INTO wf_mailer_parameters
        (name, parameter, value, required, cb, allow_reload)
        VALUES (pName, pParameter, pValue, pRequired, pCB, pAllowReload);
     END IF;
   EXCEPTION
      WHEN OTHERS THEN RAISE;
   END;

   -- PRIVATE
   -- PutValue - Assign a value to the Node/Parameter combination
   -- IN
   -- Name for the mailer instance
   -- Name of the parameter
   -- The value to set the parameter to.
   PROCEDURE PutValue(pName IN VARCHAR2, pParam IN VARCHAR2,
                      pvalue IN VARCHAR2)
   IS
   BEGIN
      if (pName is not null and pvalue is not null) then
         UPDATE wf_mailer_parameters
         SET value = pvalue
         where name = pName
           and parameter = pParam;
         if SQL%notfound then
            INSERT INTO
               wf_mailer_parameters
               (name, parameter, value, required, cb, allow_reload)
               SELECT pName,
               pParam,
               pvalue,
               wp.required,
               wp.cb,
               wp.allow_reload
               FROM wf_mailer_parameters wp
               WHERE NAME = default_name
                 and parameter = pParam;
         end if;
      end if;
      if pvalue is null then
         DELETE wf_mailer_parameters
         WHERE name = pName
           AND parameter = pParam;
      end if;
   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'PutValue', pName, pParam);
         raise;
   END PutValue;


   -- Validate - To use the call back within the wf_mailer_parameters
   --            in order to provide some validation on the parameter
   -- IN
   --   Parameter to be checked
   --   value to check
   -- OUT
   --   Result of the validation
   PROCEDURE Validate(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult OUT NOCOPY VARCHAR2)
   IS
      funName VARCHAR2(60);
      sqlBuf VARCHAR2 (200);
      result VARCHAR2(100);
   BEGIN
      BEGIN
         SELECT cb
         INTO funName
         FROM wf_mailer_parameters
         WHERE name = default_name
           AND parameter = pParam;
         pResult := valid_param;
      EXCEPTION
         WHEN no_data_found THEN
            wf_core.token('PARAMETER',pParam);
            wf_core.token('VALUE',pValue);
            pResult := wf_core.Substitute('WFERR', 'WFMLR_NO_PARAMETER');
            funName := no_validation;
         WHEN OTHERS THEN RAISE;
      END;
      IF funName <> no_validation THEN
         sqlBuf := 'begin '||funName||' (:param, :value, :result); end;';
         EXECUTE IMMEDIATE sqlBuf USING
          IN pParam,
          IN pValue,
          IN OUT Result;

          pResult := NVL(result, valid_param);
      END IF;

   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'Validate', pParam, pValue);
         raise;
   END Validate;



   -- PUBLIC
   -- PutValue - Assign a value to the Node/Parameter combination
   -- IN
   -- Name for the mailer instance
   -- Name of the parameter
   -- The value to set the parameter to.
   -- Return message
   PROCEDURE PutValue(pName IN VARCHAR2, pParam IN VARCHAR2,
                      pvalue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      IF pParam is not NULL or pParam <> '' THEN
         validate(pParam, pValue, pResult);
         IF pResult = valid_param THEN
            PutValue(pName, pParam, pValue);
         END IF;
      END IF;
   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'PutValue', pName, pParam);
         raise;
   END PutValue;

   -- PutValues - Assign a PL/SQL table of parameters value to the Parameter
   --             table
   -- IN
   -- Name for the mailer instance
   -- PL/SQL table of parameter values.
   PROCEDURE PutValues(pName IN VARCHAR2,
                       pParams IN OUT NOCOPY wf_mailer_params_tbl_type)
   IS
   BEGIN
      if pParams.COUNT = 0 then
         return;
      END IF;
      FOR i IN 1..pParams.COUNT LOOP
        PutValue(pParams(i).NAME, pParams(i).PARAMETER, pParams(i).VALUE,
                 pParams(i).ERRMSG);
      END LOOP;
   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'PutValues', pName);
         raise;
   END PutValues;

   -- get_mailer_tags_c - Return the REF Cursor for the list of tags
   -- IN
   -- Service name
   -- RETURN
   -- wf_mailer_tags_c type
   FUNCTION get_mailer_tags_c(pServiceName IN VARCHAR2)
     RETURN wf_mailer_tags_c
   AS
     v_cursor wf_mailer_tags_c;

   BEGIN
     OPEN v_cursor FOR
        SELECT name, tag_id, action, pattern
        FROM wf_mailer_tags
        WHERE name = pServiceName
        UNION
        SELECT name, tag_id, action, pattern
        FROM wf_mailer_tags
        WHERE name = '-WF_DEFAULT-';

     RETURN v_cursor;
   END get_mailer_tags_c;


   -- GetTAGs - Return a list of tags and their actions
   -- IN
   -- The name for the instance
   -- OUT
   -- The list of tags in a PL/SQL Table of wf_mailer_tags_rec_type
   PROCEDURE GetTAGS(pName IN VARCHAR2, pTags in out NOCOPY wf_mailer_tags_tbl_type)
   IS
      lName VARCHAR2(12);
      CURSOR c is
      SELECT name, tag_id, pattern, action
      FROM wf_mailer_tags
      WHERE name = lName;

      i integer;

   BEGIN
      lName := DEFAULT_NAME;
      i := 1;
      for r in c loop
         pTags(i) := r;
         pTags(i).name := pName;
         i := i + 1;
      end loop;

      lName := pName;
      for r in c loop
         pTags(i) := r;
         i := i + 1;
      end loop;

   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'GetTAGs', pName);
         raise;
   END GetTags;


   -- PutTAG - Updates or inserts a new TAG reference
   -- IN
   -- The name for the instance
   -- The id for the specific tag
   -- The action to take if the pattern is matched
   -- The pattern to match
   PROCEDURE PutTAG(pName IN VARCHAR2, ptag_id in NUMBER, paction IN VARCHAR2,
          ppattern IN VARCHAR2)
   IS
      tagExists number;
   BEGIN

      -- OAM UI : Always pass tagId as "-1" for each new user defined tags.
      if ptag_id is null then
         return;
      end if;

      -- Loader and OAM UI(to update / delete a user defined Tags) specific logic .
      IF (ptag_id > 0 ) then

         select count(1)
         into   tagExists
         from   wf_mailer_tags
         WHERE  tag_id  = pTag_id;

	 if tagExists > 0 then
	   if paction is null and ppattern is null then
	       DELETE wf_mailer_tags
	       WHERE name = pName
	       AND tag_id = ptag_id;
	   else
	      UPDATE wf_mailer_tags
	      SET action = paction,
		  pattern = ppattern
	      WHERE name = pName
	      AND tag_id = ptag_id;
	   end if;
	 else
           -- Tag does not exist, insert it,
	   -- This will only be executed for Loader
	   INSERT INTO wf_mailer_tags
		    (name,
		    tag_id,
		    action,
		    pattern)
             VALUES (pName,
                     pTag_id,
                     paction,
                     ppattern);
	 end if;
      else
         -- ptag_id is not greater than 0  (-1 being passed from UI)
	 -- Check if tag exist based on NODENAME, Action, Pattern
	 -- So that we don't have duplicate (same action, pattern) Tags
         select count(1)
         into   tagExists
         from   wf_mailer_tags
         where  action  = paction
	 and    pattern = ppattern
	 and    name    = pName  ;

	 --  Insert unique tags
	 if(nvl(tagExists, 0) = 0) then
           INSERT INTO wf_mailer_tags
		    (name,
		    tag_id,
		    action,
		    pattern)
             VALUES (pName,
                     wf_mailer_tags_s.nextval,
                     paction,
                     ppattern);
          end if;
       end if;

   EXCEPTION
      when others then
         wf_core.Context('Wf_Mailer_Parameters', 'PutTAGs', pName,
                         to_char(ptag_id), paction, ppattern);
         raise;
   END PutTag;

   -- PutTAG - Updates or inserts a new TAG reference
   -- IN
   -- The name for the instance
   -- The id for the specific tag
   -- The action to take if the pattern is matched
   -- The pattern to match
   -- The result of the PUT operation
   PROCEDURE PutTAG(pName IN VARCHAR2, ptag_id in NUMBER, paction IN VARCHAR2,
          ppattern IN VARCHAR2, pResult OUT NOCOPY VARCHAR2)
   IS
      errname VARCHAR2(30);
      errmsg VARCHAR2(2000);
      errstack VARCHAR2(32000);
   BEGIN
      PutTAG(pName, pTag_ID, pAction, pPattern);
      pResult := valid_param;
   EXCEPTION
      when others then
         wf_core.Get_Error(errname, errmsg, errstack);
         wf_core.token('TAGID',to_char(pTag_ID));
         wf_core.token('ACTION', pAction);
         wf_core.token('PATTERN',pPattern);
         wf_core.token('ERRNAME', errname);
         wf_core.token('ERRMSG', errmsg);
         wf_core.token('STACK', errstack);
         pResult := wf_core.Substitute('WFERR', 'WFMLR_BAD_TAG');
   END PutTag;

   -- GetValues - To return a PL/SQL table of parameters
   -- IN
   -- The name for the mailer instance
   -- OUT
   -- Series of parameters and their values
   -- NOTE
   -- This overoaded from of GetValues is provided for thin
   -- java clients.
   PROCEDURE GetValues(pName IN VARCHAR2,
       pParam01 OUT NOCOPY VARCHAR2,
       pValue01 OUT NOCOPY VARCHAR2,
       pParam02 OUT NOCOPY VARCHAR2,
       pValue02 OUT NOCOPY VARCHAR2,
       pParam03 OUT NOCOPY VARCHAR2,
       pValue03 OUT NOCOPY VARCHAR2,
       pParam04 OUT NOCOPY VARCHAR2,
       pValue04 OUT NOCOPY VARCHAR2,
       pParam05 OUT NOCOPY VARCHAR2,
       pValue05 OUT NOCOPY VARCHAR2,
       pParam06 OUT NOCOPY VARCHAR2,
       pValue06 OUT NOCOPY VARCHAR2,
       pParam07 OUT NOCOPY VARCHAR2,
       pValue07 OUT NOCOPY VARCHAR2,
       pParam08 OUT NOCOPY VARCHAR2,
       pValue08 OUT NOCOPY VARCHAR2,
       pParam09 OUT NOCOPY VARCHAR2,
       pValue09 OUT NOCOPY VARCHAR2,
       pParam10 OUT NOCOPY VARCHAR2,
       pValue10 OUT NOCOPY VARCHAR2,
       pParam11 OUT NOCOPY VARCHAR2,
       pValue11 OUT NOCOPY VARCHAR2,
       pParam12 OUT NOCOPY VARCHAR2,
       pValue12 OUT NOCOPY VARCHAR2,
       pParam13 OUT NOCOPY VARCHAR2,
       pValue13 OUT NOCOPY VARCHAR2,
       pParam14 OUT NOCOPY VARCHAR2,
       pValue14 OUT NOCOPY VARCHAR2,
       pParam15 OUT NOCOPY VARCHAR2,
       pValue15 OUT NOCOPY VARCHAR2,
       pParam16 OUT NOCOPY VARCHAR2,
       pValue16 OUT NOCOPY VARCHAR2,
       pParam17 OUT NOCOPY VARCHAR2,
       pValue17 OUT NOCOPY VARCHAR2,
       pParam18 OUT NOCOPY VARCHAR2,
       pValue18 OUT NOCOPY VARCHAR2,
       pParam19 OUT NOCOPY VARCHAR2,
       pValue19 OUT NOCOPY VARCHAR2,
       pParam20 OUT NOCOPY VARCHAR2,
       pValue20 OUT NOCOPY VARCHAR2,
       pParam21 OUT NOCOPY VARCHAR2,
       pValue21 OUT NOCOPY VARCHAR2,
       pParam22 OUT NOCOPY VARCHAR2,
       pValue22 OUT NOCOPY VARCHAR2,
       pParam23 OUT NOCOPY VARCHAR2,
       pValue23 OUT NOCOPY VARCHAR2,
       pParam24 OUT NOCOPY VARCHAR2,
       pValue24 OUT NOCOPY VARCHAR2,
       pParam25 OUT NOCOPY VARCHAR2,
       pValue25 OUT NOCOPY VARCHAR2,
       pParam26 OUT NOCOPY VARCHAR2,
       pValue26 OUT NOCOPY VARCHAR2,
       pParam27 OUT NOCOPY VARCHAR2,
       pValue27 OUT NOCOPY VARCHAR2,
       pParam28 OUT NOCOPY VARCHAR2,
       pValue28 OUT NOCOPY VARCHAR2,
       pParam29 OUT NOCOPY VARCHAR2,
       pValue29 OUT NOCOPY VARCHAR2,
       pParam30 OUT NOCOPY VARCHAR2,
       pValue30 OUT NOCOPY VARCHAR2,
       pParam31 OUT NOCOPY VARCHAR2,
       pValue31 OUT NOCOPY VARCHAR2,
       pParam32 OUT NOCOPY VARCHAR2,
       pValue32 OUT NOCOPY VARCHAR2,
       pParam33 OUT NOCOPY VARCHAR2,
       pValue33 OUT NOCOPY VARCHAR2,
       pParam34 OUT NOCOPY VARCHAR2,
       pValue34 OUT NOCOPY VARCHAR2,
       pParam35 OUT NOCOPY VARCHAR2,
       pValue35 OUT NOCOPY VARCHAR2,
       pParam36 OUT NOCOPY VARCHAR2,
       pValue36 OUT NOCOPY VARCHAR2,
       pParam37 OUT NOCOPY VARCHAR2,
       pValue37 OUT NOCOPY VARCHAR2,
       pParam38 OUT NOCOPY VARCHAR2,
       pValue38 OUT NOCOPY VARCHAR2,
       pParam39 OUT NOCOPY VARCHAR2,
       pValue39 OUT NOCOPY VARCHAR2,
       pParam40 OUT NOCOPY VARCHAR2,
       pValue40 OUT NOCOPY VARCHAR2
   ) AS
      params wf_mailer_params_tbl_type;
      param wf_mailer_params_rec_type;
   BEGIN
      GetValues(pName, params);
      param.Name := pName;
      param.Parameter := NULL;
      param.Value := NULL;
      FOR i in params.COUNT+1..40 LOOP
         params(i) := param;
      END LOOP;
      pParam01 := params( 1).Parameter; pValue01 := params( 1).Value;
      pParam02 := params( 2).Parameter; pValue02 := params( 2).Value;
      pParam03 := params( 3).Parameter; pValue03 := params( 3).Value;
      pParam04 := params( 4).Parameter; pValue04 := params( 4).Value;
      pParam05 := params( 5).Parameter; pValue05 := params( 5).Value;
      pParam06 := params( 6).Parameter; pValue06 := params( 6).Value;
      pParam07 := params( 7).Parameter; pValue07 := params( 7).Value;
      pParam08 := params( 8).Parameter; pValue08 := params( 8).Value;
      pParam09 := params( 9).Parameter; pValue09 := params( 9).Value;
      pParam10 := params(10).Parameter; pValue10 := params(10).Value;
      pParam11 := params(11).Parameter; pValue11 := params(11).Value;
      pParam12 := params(12).Parameter; pValue12 := params(12).Value;
      pParam13 := params(13).Parameter; pValue13 := params(13).Value;
      pParam14 := params(14).Parameter; pValue14 := params(14).Value;
      pParam15 := params(15).Parameter; pValue15 := params(15).Value;
      pParam16 := params(16).Parameter; pValue16 := params(16).Value;
      pParam17 := params(17).Parameter; pValue17 := params(17).Value;
      pParam18 := params(18).Parameter; pValue18 := params(18).Value;
      pParam19 := params(19).Parameter; pValue19 := params(19).Value;
      pParam20 := params(20).Parameter; pValue20 := params(20).Value;
      pParam21 := params(21).Parameter; pValue21 := params(21).Value;
      pParam22 := params(22).Parameter; pValue22 := params(22).Value;
      pParam23 := params(23).Parameter; pValue23 := params(23).Value;
      pParam24 := params(24).Parameter; pValue24 := params(24).Value;
      pParam25 := params(25).Parameter; pValue25 := params(25).Value;
      pParam26 := params(26).Parameter; pValue26 := params(26).Value;
      pParam27 := params(27).Parameter; pValue27 := params(27).Value;
      pParam28 := params(28).Parameter; pValue28 := params(28).Value;
      pParam29 := params(29).Parameter; pValue29 := params(29).Value;
      pParam30 := params(30).Parameter; pValue30 := params(30).Value;
      pParam31 := params(31).Parameter; pValue31 := params(31).Value;
      pParam32 := params(32).Parameter; pValue32 := params(32).Value;
      pParam33 := params(33).Parameter; pValue33 := params(33).Value;
      pParam34 := params(34).Parameter; pValue34 := params(34).Value;
      pParam35 := params(35).Parameter; pValue35 := params(35).Value;
      pParam36 := params(36).Parameter; pValue36 := params(36).Value;
      pParam37 := params(37).Parameter; pValue37 := params(37).Value;
      pParam38 := params(38).Parameter; pValue38 := params(38).Value;
      pParam39 := params(39).Parameter; pValue39 := params(39).Value;
      pParam40 := params(40).Parameter; pValue40 := params(40).Value;
   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'GetValues', pName);
         raise;
   END GetValues;


   -- PutValues - Assign a PL/SQL table of parameters value to the Parameter
   --             table
   -- IN
   -- Name for the mailer instance
   -- PL/SQL table of parameter values.
   -- This overoaded from of PutValues is provided for thin
   -- java clients.
   PROCEDURE PutValues(pName IN VARCHAR2,
                       pFlag OUT NOCOPY VARCHAR2,
       pParam01 IN OUT NOCOPY VARCHAR2,
       pValue01 IN OUT NOCOPY VARCHAR2, pResult01 OUT VARCHAR2,
       pParam02 IN OUT NOCOPY VARCHAR2,
       pValue02 IN OUT NOCOPY VARCHAR2, pResult02 OUT VARCHAR2,
       pParam03 IN OUT NOCOPY VARCHAR2,
       pValue03 IN OUT NOCOPY VARCHAR2, pResult03 OUT VARCHAR2,
       pParam04 IN OUT NOCOPY VARCHAR2,
       pValue04 IN OUT NOCOPY VARCHAR2, pResult04 OUT VARCHAR2,
       pParam05 IN OUT NOCOPY VARCHAR2,
       pValue05 IN OUT NOCOPY VARCHAR2, pResult05 OUT VARCHAR2,
       pParam06 IN OUT NOCOPY VARCHAR2,
       pValue06 IN OUT NOCOPY VARCHAR2, pResult06 OUT VARCHAR2,
       pParam07 IN OUT NOCOPY VARCHAR2,
       pValue07 IN OUT NOCOPY VARCHAR2, pResult07 OUT VARCHAR2,
       pParam08 IN OUT NOCOPY VARCHAR2,
       pValue08 IN OUT NOCOPY VARCHAR2, pResult08 OUT VARCHAR2,
       pParam09 IN OUT NOCOPY VARCHAR2,
       pValue09 IN OUT NOCOPY VARCHAR2, pResult09 OUT VARCHAR2,
       pParam10 IN OUT NOCOPY VARCHAR2,
       pValue10 IN OUT NOCOPY VARCHAR2, pResult10 OUT VARCHAR2,
       pParam11 IN OUT NOCOPY VARCHAR2,
       pValue11 IN OUT NOCOPY VARCHAR2, pResult11 OUT VARCHAR2,
       pParam12 IN OUT NOCOPY VARCHAR2,
       pValue12 IN OUT NOCOPY VARCHAR2, pResult12 OUT VARCHAR2,
       pParam13 IN OUT NOCOPY VARCHAR2,
       pValue13 IN OUT NOCOPY VARCHAR2, pResult13 OUT VARCHAR2,
       pParam14 IN OUT NOCOPY VARCHAR2,
       pValue14 IN OUT NOCOPY VARCHAR2, pResult14 OUT VARCHAR2,
       pParam15 IN OUT NOCOPY VARCHAR2,
       pValue15 IN OUT NOCOPY VARCHAR2, pResult15 OUT VARCHAR2,
       pParam16 IN OUT NOCOPY VARCHAR2,
       pValue16 IN OUT NOCOPY VARCHAR2, pResult16 OUT VARCHAR2,
       pParam17 IN OUT NOCOPY VARCHAR2,
       pValue17 IN OUT NOCOPY VARCHAR2, pResult17 OUT VARCHAR2,
       pParam18 IN OUT NOCOPY VARCHAR2,
       pValue18 IN OUT NOCOPY VARCHAR2, pResult18 OUT VARCHAR2,
       pParam19 IN OUT NOCOPY VARCHAR2,
       pValue19 IN OUT NOCOPY VARCHAR2, pResult19 OUT VARCHAR2,
       pParam20 IN OUT NOCOPY VARCHAR2,
       pValue20 IN OUT NOCOPY VARCHAR2, pResult20 OUT VARCHAR2,
       pParam21 IN OUT NOCOPY VARCHAR2,
       pValue21 IN OUT NOCOPY VARCHAR2, pResult21 OUT VARCHAR2,
       pParam22 IN OUT NOCOPY VARCHAR2,
       pValue22 IN OUT NOCOPY VARCHAR2, pResult22 OUT VARCHAR2,
       pParam23 IN OUT NOCOPY VARCHAR2,
       pValue23 IN OUT NOCOPY VARCHAR2, pResult23 OUT VARCHAR2,
       pParam24 IN OUT NOCOPY VARCHAR2,
       pValue24 IN OUT NOCOPY VARCHAR2, pResult24 OUT VARCHAR2,
       pParam25 IN OUT NOCOPY VARCHAR2,
       pValue25 IN OUT NOCOPY VARCHAR2, pResult25 OUT VARCHAR2,
       pParam26 IN OUT NOCOPY VARCHAR2,
       pValue26 IN OUT NOCOPY VARCHAR2, pResult26 OUT VARCHAR2,
       pParam27 IN OUT NOCOPY VARCHAR2,
       pValue27 IN OUT NOCOPY VARCHAR2, pResult27 OUT VARCHAR2,
       pParam28 IN OUT NOCOPY VARCHAR2,
       pValue28 IN OUT NOCOPY VARCHAR2, pResult28 OUT VARCHAR2,
       pParam29 IN OUT NOCOPY VARCHAR2,
       pValue29 IN OUT NOCOPY VARCHAR2, pResult29 OUT VARCHAR2,
       pParam30 IN OUT NOCOPY VARCHAR2,
       pValue30 IN OUT NOCOPY VARCHAR2, pResult30 OUT VARCHAR2,
       pParam31 IN OUT NOCOPY VARCHAR2,
       pValue31 IN OUT NOCOPY VARCHAR2, pResult31 OUT VARCHAR2,
       pParam32 IN OUT NOCOPY VARCHAR2,
       pValue32 IN OUT NOCOPY VARCHAR2, pResult32 OUT VARCHAR2,
       pParam33 IN OUT NOCOPY VARCHAR2,
       pValue33 IN OUT NOCOPY VARCHAR2, pResult33 OUT VARCHAR2,
       pParam34 IN OUT NOCOPY VARCHAR2,
       pValue34 IN OUT NOCOPY VARCHAR2, pResult34 OUT VARCHAR2,
       pParam35 IN OUT NOCOPY VARCHAR2,
       pValue35 IN OUT NOCOPY VARCHAR2, pResult35 OUT VARCHAR2,
       pParam36 IN OUT NOCOPY VARCHAR2,
       pValue36 IN OUT NOCOPY VARCHAR2, pResult36 OUT VARCHAR2,
       pParam37 IN OUT NOCOPY VARCHAR2,
       pValue37 IN OUT NOCOPY VARCHAR2, pResult37 OUT VARCHAR2,
       pParam38 IN OUT NOCOPY VARCHAR2,
       pValue38 IN OUT NOCOPY VARCHAR2, pResult38 OUT VARCHAR2,
       pParam39 IN OUT NOCOPY VARCHAR2,
       pValue39 IN OUT NOCOPY VARCHAR2, pResult39 OUT VARCHAR2,
       pParam40 IN OUT NOCOPY VARCHAR2,
       pValue40 IN OUT NOCOPY VARCHAR2, pResult40 OUT VARCHAR2
   ) AS
      params wf_mailer_params_tbl_type;
      param wf_mailer_params_rec_type;
   BEGIN
      putValue(pName, pParam01, pValue01, pResult01);
      putValue(pName, pParam02, pValue02, pResult02);
      putValue(pName, pParam03, pValue03, pResult03);
      putValue(pName, pParam04, pValue04, pResult04);
      putValue(pName, pParam05, pValue05, pResult05);
      putValue(pName, pParam06, pValue06, pResult06);
      putValue(pName, pParam07, pValue07, pResult07);
      putValue(pName, pParam08, pValue08, pResult08);
      putValue(pName, pParam09, pValue09, pResult09);
      putValue(pName, pParam10, pValue10, pResult10);
      putValue(pName, pParam11, pValue11, pResult11);
      putValue(pName, pParam12, pValue12, pResult12);
      putValue(pName, pParam13, pValue13, pResult13);
      putValue(pName, pParam14, pValue14, pResult14);
      putValue(pName, pParam15, pValue15, pResult15);
      putValue(pName, pParam16, pValue16, pResult16);
      putValue(pName, pParam17, pValue17, pResult17);
      putValue(pName, pParam18, pValue18, pResult18);
      putValue(pName, pParam19, pValue19, pResult19);
      putValue(pName, pParam20, pValue20, pResult20);
      putValue(pName, pParam21, pValue21, pResult21);
      putValue(pName, pParam22, pValue22, pResult22);
      putValue(pName, pParam23, pValue23, pResult23);
      putValue(pName, pParam24, pValue24, pResult24);
      putValue(pName, pParam25, pValue25, pResult25);
      putValue(pName, pParam26, pValue26, pResult26);
      putValue(pName, pParam27, pValue27, pResult27);
      putValue(pName, pParam38, pValue28, pResult28);
      putValue(pName, pParam39, pValue29, pResult29);
      putValue(pName, pParam30, pValue30, pResult30);
      putValue(pName, pParam31, pValue31, pResult31);
      putValue(pName, pParam32, pValue32, pResult32);
      putValue(pName, pParam33, pValue33, pResult33);
      putValue(pName, pParam34, pValue34, pResult34);
      putValue(pName, pParam35, pValue35, pResult35);
      putValue(pName, pParam36, pValue36, pResult36);
      putValue(pName, pParam37, pValue37, pResult37);
      putValue(pName, pParam38, pValue38, pResult38);
      putValue(pName, pParam39, pValue39, pResult39);
      putValue(pName, pParam40, pValue40, pResult40);

   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'PutValues', pName);
         raise;
   END PutValues;

   -- ValidSTR
   -- Validate a string value. Basic rule is that it can not
   -- be NULL;
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidSTR(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2)
   IS
      l_required VARCHAR2(1);
      l_default VARCHAR2(200);
   BEGIN

      SELECT value, required
      into l_default, l_required
      FROM wf_mailer_parameters
      WHERE name = default_name
        AND parameter = pParam;
      IF (pValue IS NULL or pValue = '') AND l_required = 'Y' THEN
         wf_core.token('PARAMETER', pParam);
         wf_core.token('VALUE', pvalue);
         pResult := wf_core.Substitute('WFERR', 'WFMLR_NULL_PARAMETER');
      ELSIF  pValue = l_default AND l_required = 'Y' THEN
         wf_core.token('PARAMETER', pParam);
         wf_core.token('VALUE', pvalue);
         pResult := wf_core.Substitute('WFERR', 'WFMLR_REQUIRED_PARAMETER');
      ELSE
         pResult := valid_param;
      END IF;
   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'ValidStr', pParam, pValue,
                         pResult);
         raise;
   END ValidSTR;


   -- ValidINT
   -- Validate a numeric value. Basic rule is that it can not
   -- be NULL and must be a valid number;
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidINT(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2)
   IS
      numVal NUMBER;
   BEGIN
      IF pValue IS NULL or pValue = '' THEN
         pResult := valid_param;
      ELSE
         BEGIN
            SELECT pValue
            INTO numVal
            FROM sys.dual;
            pResult := valid_param;
         EXCEPTION
            WHEN OTHERS THEN
               wf_core.token('PARAMETER', pParam);
               wf_core.token('VALUE', pvalue);
               pResult := wf_core.Substitute('WFERR', 'WFMLR_BADNUMBER');
         END;
      END IF;

   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'ValidINT', pParam, pValue,
                         pResult);
         raise;
   END ValidINT;


   -- ValidLOG
   -- Validate a boolean value. Basic rule is that it can not
   -- be YES/NO
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidLOG(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      IF upper(pValue) NOT IN ('Y','N','YES','NO') then
         wf_core.token('PARAMETER', pParam);
         wf_core.token('VALUE', pvalue);
         pResult := wf_core.Substitute('WFERR', 'WFMLR_BADBOOL');
      ELSE
         pResult := valid_param;
      END IF;
   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'ValidLOG', pParam, pValue,
                         pResult);
         raise;
   END ValidLOG;


   -- ValidPROTOCOL
   -- Validate a protocol
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidPROTOCOL(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      IF upper(pValue) NOT IN ('POP3','IMAP') then
         wf_core.token('PARAMETER', pParam);
         wf_core.token('VALUE', pvalue);
         pResult := wf_core.Substitute('WFERR', 'WFMLR_BADPROTOCOL');
      ELSE
         pResult := valid_param;
      END IF;
   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'ValidPROTOCOL',
                         pParam, pValue, pResult);
         raise;
   END ValidPROTOCOL;


   -- ValidSENDARG
   -- Validate the sendmail arguments
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidSENDARG(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2)
   IS
      valid integer := 0;
   BEGIN
      BEGIN
         SELECT 1 into valid
         FROM sys.dual
               WHERE pValue like '%%%s%-t%-F%"%%s"%<%%%s';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            valid := 0;
      END;
      IF pValue IS NOT NULL AND  VALID = 0 THEN
         wf_core.token('PARAMETER', pParam);
         wf_core.token('VALUE', pvalue);
         pResult := wf_core.Substitute('WFERR', 'WFMLR_BAD_SENDMAILARG');
      ELSE
         pResult := valid_param;
      END IF;
   EXCEPTION
      WHEN Others THEN
         wf_core.Context('Wf_Mailer_Parameters', 'ValidPROTOCOL',
                         pParam, pValue, pResult);
         raise;
   END ValidSENDARG;

--------------------------------------------------------------------------
-- GetValueForCorr - To return a parameter value
-- IN
-- The correlation id for the mailer instance
-- The name of the parameter
-- RETURNS
-- the value of the parameter.
FUNCTION GetValueForCorr(pCorrId IN VARCHAR2, pName IN VARCHAR2) RETURN VARCHAR2
IS

l_component_id fnd_svc_components.component_id%TYPE;
l_value fnd_svc_comp_param_vals.parameter_value%TYPE;
l_component_found boolean;
l_corrid varchar2(40);

CURSOR c_get_components_for_corr is
	SELECT component_id
	FROM FND_SVC_COMPONENTS
	WHERE
		l_corrid like correlation_id and
		component_type = 'WF_MAILER'
	order by DECODE(component_status, 'RUNNING', 1, 'NOT_CONFIGURED', 3, 2) ASC ;

CURSOR c_get_components_for_null_corr is
	SELECT component_id
	FROM FND_SVC_COMPONENTS
	WHERE
		correlation_id is null and
		component_type = 'WF_MAILER'
	order by DECODE(component_status, 'RUNNING', 1, 'NOT_CONFIGURED', 3, 2) ASC ;


BEGIN

        -- If correlation id does not contain message name, add : to it
        -- in order to get reliable result from SVC component definition
        if (pCorrId is not null and instr(pCorrId, ':') = 0) then
          l_corrid := pCorrId||':';
        else
          l_corrid := pCorrId;
        end if;

        l_component_found := FALSE;

	if l_corrid is not null then
		for rec_component in c_get_components_for_corr loop
			l_component_id := rec_component.component_id;
			l_component_found := TRUE;
			exit;
		end loop;
	END IF;

	if not l_component_found then
		for rec_component_null in c_get_components_for_null_corr loop
			l_component_id := rec_component_null.component_id;
			l_component_found := TRUE;
			exit;
		end loop;
	END IF;

	if l_component_found then
		l_value := FND_SVC_COMPONENT.Retrieve_Parameter_Value
				(p_parameter_name => pName,
				p_component_id => l_component_id);
	END IF;

	return l_value;

EXCEPTION
	when others then
	wf_core.Context('Wf_Mailer_Parameters', 'GetValueForCorr',
				'CorrId:'||l_corrid, 'Parameter:'||pName);
	raise;
END GetValueForCorr;


-- GetValueForCorr - To return a parameter value based on the
--                   content of the message attribute of with the
--                   name pattern of #WFM_<PARAM>
-- IN
-- The Notification ID
-- The correlation id for the mailer instance
-- The name of the parameter
-- RETURNS
-- the value of the parameter.
FUNCTION GetValueForCorr(pNid IN VARCHAR2, pCorrId IN VARCHAR2,
                         pName IN VARCHAR2,
                         pInAttr OUT NOCOPY varchar2) RETURN VARCHAR2
IS

l_value fnd_svc_comp_param_vals.parameter_value%TYPE;

BEGIN
   pInAttr := 'N';
   begin
      l_value := wf_notification.getAttrText(pNid, '#WFM_'||pName);
      pInAttr := 'Y';
   exception
      when others then
         if (wf_core.error_name = 'WFNTF_ATTR') then
            Wf_Core.Clear;
            pInAttr := 'N';
         else
            raise;
         end if;
   end;
   if (pInAttr = 'Y' and l_value is not null) then
      return l_value;
   end if;

   return getValueForCorr(pCorrId, pName);


EXCEPTION
   when others then
   wf_core.Context('Wf_Mailer_Parameters', 'GetValueForCorr',
                   'pNid: '||pNid, 'CorrId:'||pCorrId,
                   'Parameter:'||pName);
   raise;
END GetValueForCorr;

end WF_MAILER_PARAMETER;

/
