--------------------------------------------------------
--  DDL for Package WF_MAILER_PARAMETER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MAILER_PARAMETER" AUTHID CURRENT_USER as
/* $Header: wfmlrps.pls 120.2.12000000.1 2007/01/18 13:48:54 appldev ship $ */
--------------------------------------------------------------------------
--
-- PRIVATE global variables
--
TYPE wf_mailer_tags_rec_type IS RECORD
(
   NAME    varchar2(12),
   TAG_ID  NUMBER,
   PATTERN varchar2(200),
   ACTION  varchar2(8)
);
TYPE wf_mailer_tags_tbl_type is TABLE OF wf_mailer_tags_rec_type
   INDEX BY BINARY_INTEGER;

TYPE wf_mailer_params_rec_type IS RECORD
(
   NAME varchar2(12),
   PARAMETER varchar2(30),
   VALUE varchar2 (200),
   REQUIRED varchar2(1),
   ERRMSG   varchar2(30)
);
TYPE wf_mailer_params_tbl_type is TABLE OF wf_mailer_params_rec_type
   INDEX BY BINARY_INTEGER;

TYPE wf_mailer_tags_c IS REF CURSOR;

--------------------------------------------------------------------------
   -- GetValue - To return a parameter value
   -- IN
   -- The name for the mailer instance
   -- The name of the parameter
   -- RETURNS
   -- the value of the node/parameter combination. If this
   -- does not exist, then the -WF_DEFAULT-/parameter combination
   FUNCTION GetValue(pName IN VARCHAR2, pParam IN VARCHAR2) RETURN VARCHAR2;

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
            RETURN VARCHAR2;

   -- GetValues - To return a PL/SQL table of parameters
   -- IN
   -- The name for the mailer instance
   -- OUT
   -- PL/SQL table of the parameters for the speicified mailer name.
   PROCEDURE GetValues(pName IN VARCHAR2,
                       pParams IN OUT NOCOPY wf_mailer_params_tbl_type);

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
   );

   -- PRIVATE
   -- PutParameter - To insert a new parameter. For use by the
   --                loader.
   PROCEDURE PutParameter(pName IN VARCHAR2, pParameter IN VARCHAR2,
                          pValue IN VARCHAR2, pRequired IN VARCHAR2,
                          pCB IN VARCHAR2, pAllowReload IN VARCHAR2);

   -- PUBLIC
   -- PutValue - Assign a value to the Node/Parameter combination
   -- IN
   -- Name for the mailer instance
   -- Name of the parameter
   -- The value to set the parameter to.
   -- Return message
   PROCEDURE PutValue(pName IN VARCHAR2, pParam IN VARCHAR2,
                      pvalue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2);

   -- PUBLIC
   -- PutValues - Assign a PL/SQL table of parameters value to the Parameter
   --             table
   -- IN
   -- Name for the mailer instance
   -- PL/SQL table of parameter values.
   PROCEDURE PutValues(pName IN VARCHAR2,
                       pParams IN OUT NOCOPY wf_mailer_params_tbl_type);

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
   );


   -- get_mailer_tags_c - Return the REF Cursor for the list of tags
   -- IN
   -- Service name
   -- RETURN
   -- wf_mailer_tags_c type
   FUNCTION get_mailer_tags_c(pServiceName IN VARCHAR2)
       RETURN wf_mailer_tags_c;


   -- GetTAGs - Return a list of tags and their actions
   -- IN
   -- The name for the instance
   -- OUT
   -- The list of tags in a PL/SQL Table of wf_mailer_tags_rec_type
   PROCEDURE GetTAGS(pName IN VARCHAR2, pTags in out NOCOPY wf_mailer_tags_tbl_type);

   -- PutTAG - Updates or inserts a new TAG reference
   -- IN
   -- The name for the instance
   -- The id for the specific tag
   -- The action to take if the pattern is matched
   -- The pattern to match
   PROCEDURE PutTAG(pName IN VARCHAR2, ptag_id in NUMBER, paction IN VARCHAR2,
          ppattern IN VARCHAR2);

   -- PutTAG - Updates or inserts a new TAG reference
   -- IN
   -- The name for the instance
   -- The id for the specific tag
   -- The action to take if the pattern is matched
   -- The patter to match
   -- The result of the put operation
   PROCEDURE PutTAG(pName IN VARCHAR2, ptag_id in NUMBER, paction IN VARCHAR2,
          ppattern IN VARCHAR2, pResult OUT NOCOPY VARCHAR2);

   -- ValidSTR
   -- Validate a string value. Basic rule is that it can not
   -- be NULL;
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidSTR(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2);

   -- ValidINT
   -- Validate a numeric value. Basic rule is that it can not
   -- be NULL and must be a valid number;
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidINT(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2);

   -- ValidLOG
   -- Validate a boolean value. Basic rule is that it can not
   -- be YES/NO
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidLOG(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2);


   -- Validate a protocol
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidPROTOCOL(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2);

   -- ValidSENDARG
   -- Validate the sendmail arguments
   -- IN
   --  Parameter to validate
   --  Value to validate
   -- OUT
   -- Result of the validatation
   PROCEDURE ValidSENDARG(pParam IN VARCHAR2, pValue IN VARCHAR2,
                      pResult IN OUT NOCOPY VARCHAR2);

   FUNCTION GetValueForCorr (pCorrId IN VARCHAR2, pName IN VARCHAR2) RETURN VARCHAR2;


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
                         pInAttr OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


end WF_MAILER_PARAMETER;

 

/
