--------------------------------------------------------
--  DDL for Package CLN_RN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_RN_UTILS" AUTHID CURRENT_USER AS
/* $Header: CLNRNUTS.pls 120.6 2006/04/06 01:42:14 amchaudh noship $ */

     -- Name
     --   CONVERT_TO_RN_TIMEZONE
     -- Purpose

     --   Converts a date value from server time zone into RosettaNet time zone
     -- Arguments
     --   Date
     -- Notes
     --
   PROCEDURE CONVERT_TO_RN_TIMEZONE(
     p_input_date           IN DATE,
     x_utc_date             OUT NOCOPY DATE );

    -- Name
    --   CONVERT_TO_RN_DATETIME
    -- Purpose
    --   Converts a date value into RosettaNet datetime format
    --   RosettaNet Datetime Format: YYYYMMDDThhmmss.SSSZ

    -- Arguments
    --   Date
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
   PROCEDURE CONVERT_TO_RN_DATETIME(
     p_server_date          IN DATE,
     x_rn_datetime          OUT NOCOPY VARCHAR2);


    -- Name
    --   CONVERT_TO_RN_DATE_EVENT
    -- Purpose
    --   Converts a date value into RosettaNet date format and time format
    --   RosettaNet Date Format: YYYYMMDDZ  Time Format : hhmmss.SSSZ
    -- Arguments
    --   Date
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_RN_DATE_EVENT(
     p_server_date              IN DATE,
     x_rn_date                  OUT NOCOPY VARCHAR2,
     x_rn_time                  OUT NOCOPY VARCHAR2);

    -- Name
    --   CONVERT_TO_RN_DATE
    -- Purpose
    --   Converts a date value into RosettaNet date format
    --   RosettaNet Date Format: YYYYMMDDZ
    -- Arguments
    --   Date
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
   PROCEDURE CONVERT_TO_RN_DATE(
     p_server_date          IN DATE,
     x_rn_date              OUT NOCOPY VARCHAR2);

      -- Name
      --   CONVERT_TO_DB_DATE
      -- Purpose
      --   Converts a date value from RosettaNet date/datetime format to db format
      --   RosettaNet Datetime Format: YYYYMMDDThhmmss.SSSZ
      --   RosettaNet Date Format    : YYYYMMDDZ
      -- Arguments

      --   Date
      -- Notes
      --   If the date passed is NULL, then sysdate is considered.
    PROCEDURE CONVERT_TO_DB_DATE(
       p_rn_date            IN VARCHAR2,
       x_db_date            OUT NOCOPY DATE);



      -- Name
      --   CONVERT_TO_DB_DATE
      -- Purpose
      --   Converts a date value from RosettaNet date/datetime format to db format
      --   RosettaNet Date Format    : YYYYMMDDZ
      --   RosettaNet Time Format    : hhmmss.SSSZ
      -- Arguments
      --   Date
      -- Notes
      --   If the date passed is NULL, then sysdate is considered.
  PROCEDURE CONVERT_TO_DB_DATE(
     p_rn_date                  IN VARCHAR2,
     p_rn_time                  IN VARCHAR2,
     x_db_date                  OUT NOCOPY DATE);


    -- Name
    --   CONVERT_Number_To_Char
    -- Purpose
    --   Converts a Number value into a character with the given format
    -- Arguments
    --   Number
    --   Format
    -- Notes
    --   If the date passed is NULL, then sysdate is considered.
   PROCEDURE CONVERT_NUMBER_TO_CHAR(
     p_number               IN NUMBER,
     p_format               IN VARCHAR2,
     x_char                 OUT NOCOPY VARCHAR2);

    -- Name
    --   GET_FROM_ROLE
    -- Purpose
    --   Gets the fromRole details
    --   based on the Organization ID
    -- Arguments
    --   Date

    -- Notes
    --   Organization ID
  PROCEDURE GET_FROM_ROLE(
     p_org_id               IN VARCHAR2,
     x_name                 OUT NOCOPY VARCHAR2,
     x_email                OUT NOCOPY VARCHAR2,
     x_telephone            OUT NOCOPY VARCHAR2,
     x_fax                  OUT NOCOPY VARCHAR2,
     x_ece_location_code    OUT NOCOPY VARCHAR2  );

    -- Name
    --   GET_TO_ROLE
    -- Purpose
    --   Gets the toRole details

    --   based on the TP Header ID
    -- Arguments
    --   TP Header ID
    -- Notes
    --   No special notes
  PROCEDURE GET_TO_ROLE(
     p_tp_header_id         IN VARCHAR2,
     x_name                 OUT NOCOPY VARCHAR2,
     x_email                OUT NOCOPY VARCHAR2,
     x_telephone            OUT NOCOPY VARCHAR2,
     x_fax                  OUT NOCOPY VARCHAR2,
     x_ece_location_code    OUT NOCOPY VARCHAR2 );


    -- Name
    --   VALIDATE_XML
    -- Purpose
    --   Called by the "CLN Validate XML" workflow activity. This procedure gets the XML payload
    --   from the workflow, does the validations. Errors out if any validation fails.
    -- Arguments
    --   Standard Workflow API signature
    -- Notes
    --   No special notes
    PROCEDURE VALIDATE_XML(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);



    -- Name
    --   GET_ITEM_CONFIG_PARAMS
    -- Purpose
    --   This is a utilty routine called from XGM to parse values for
    --   top_level, parent level line id for item configuration details
    --   from a delimitor separated, concatenated string for item configuration
    -- Arguments
    --   p_item_config_dtl_tag Input tag value from XML
    --   x_top_model_line_id   top model line id parsed from input tag-value
    --   x_link_to_line_id     link to line id parsed from input tag-value
    -- Notes
    --   No special notes
    PROCEDURE GET_ITEM_CONFIG_PARAMS(
            p_item_config_dtl_tag       IN  VARCHAR2,
            x_top_model_line_id OUT NOCOPY VARCHAR2,
            x_link_to_line_id           OUT NOCOPY VARCHAR2
            );

    -- Name
    --   CREATE_ITEM_CONFIG_TAG
    -- Purpose
    --   This is a utilty routine called from XGM to construct a
    --   a delimitor separated, concatenated string for item config linkage details
    -- Arguments
    --   p_top_model_line_id   input top model ine id field
    --   p_link_to_line_id     input link to line id field
    --   x_item_config_dtl_tag value to be used in XML
    -- Notes
    --   No special notes
    PROCEDURE CREATE_ITEM_CONFIG_TAG(
                        p_top_model_line_id        IN        VARCHAR2,
                        p_link_to_line_id                IN    VARCHAR2,
                        x_item_config_dtl_tag        OUT         NOCOPY VARCHAR2
                );




    -- Name
    --   GET_USER_ID
    -- Purpose
    --   This is a utilty routine called from XGM to get the user id when user name is given
    -- Arguments
    --   p_user_name    input user name
    --   p_user_id      output user id
    -- Notes
    --   No special notes
    Procedure get_user_id(
                       p_user_name IN VARCHAR,
                       x_user_id OUT NOCOPY NUMBER,
                       x_error_code OUT NOCOPY NUMBER,
                       x_error_message OUT NOCOPY VARCHAR);



    -- Name
    --   getPurchaseOrderNum
    -- Purpose
    --   This is a utilty routine called from XGM to get the Purchase Order Number when Po-Relnum is given
    -- Arguments
    --   PoAndRel       input Po-Relnum
    --   PoNum          output Purchase Order Num
    -- Notes
    --   No special notes


    PROCEDURE getPurchaseOrderNum(
                       p_PoAndRel        IN     VARCHAR2,
                       x_PoNum           OUT    NOCOPY  VARCHAR2);


    -- Name
    --   getPurchaseOrderNum
    -- Purpose
    --   This is a utilty routine called from XGM to get the Release Number when Po-Relnum is given
    -- Arguments
    --   PoAndRel       input Po-Relnum
    --   RelNum         output Release Num in varchar
    -- Notes
    --   No special notes
    PROCEDURE getRelNum(p_PoAndRel        IN     VARCHAR2,
                       x_RelNum          OUT    NOCOPY   VARCHAR2);




    -- Name
    --   getRelNum
    -- Purpose
    --   This is a utilty routine called from XGM to get the Release Number when Po-Relnum is given
    -- Arguments
    --   PoAndRel       input Po-Relnum
    --   RelNum         output Release Num in num
    -- Notes
    --   No special notes
    PROCEDURE getRelNum(
                     p_PoAndRel        IN     VARCHAR2,
                     x_RelNum          OUT    NOCOPY   NUMBER);

    -- Name
    --   getrevnum
    -- Purpose
    --   This is a utilty routine called from XGM to get the Revision Number
    -- Arguments
    --   PoRelAndRev       input Po_Num -RelNum:Revnum
    --   porel             output PO-REL num
    --   revnum         output rev Num
    -- Notes
    --   No special notes

   PROCEDURE getRevNum(
                    p_PORELANDREV       IN   varchar2,
                    x_porel           OUT  NOCOPY VARCHAR2,
                    x_revnum          OUT  NOCOPY VARCHAR2);

    -- Name
    --   CONCAT_PO_RELNUM
    -- Purpose
    --   This is a utilty routine called from XGM to get the Po-Relnum
    -- Arguments
    --   PoAndRel       input Po Num
    --   RelNum         input release num
    --   RelNum         output PO Num - Release Num
    -- Notes
    --   No special notes
    PROCEDURE CONCAT_PO_RELNUM(
                    p_ponum IN VARCHAR2,
                    p_porelnum IN VARCHAR2,
                    x_poandrelnum OUT NOCOPY VARCHAR2);


    -- Name
    --   CONCAT_PORELNUM_REVNUM
    -- Purpose
    --   This is a utilty routine called from XGM to get the PoRelnum: Rev Num
    -- Arguments
    --   p_porelnum       input PoRel Num
    --   p_porevnum       input release num
    --   x_porelrevnum    output PORelNum:Rev Num
    -- Notes
    --   No special notes

    PROCEDURE CONCAT_PORELNUM_REVNUM(
                    p_porelnum IN VARCHAR2,
                    p_porevnum IN VARCHAR2,
                    x_porelrevnum OUT NOCOPY VARCHAR2);


    -- Name
    --   getTagParamValue
    -- Purpose
    --   This is a utilty routine called from XGM to get the a tag value
    --   Tag and tag value tuple is separated by '='
    --   Different tags are separated by a '|'
    -- Arguments
    --   p_xml_tag        input tag path beginning with root element
    --   p_param          input tag name
    --   x_value          output tag value
    -- Notes
    --   No special notes

    PROCEDURE getTagParamValue(
                        p_xml_tag        IN VARCHAR2,
                        p_param                IN vARCHAR2,
                        x_value                OUT NOCOPY VARCHAR2);


    -- Name
    --   Get_tag_value_from_xml
    -- Purpose
    --   This is a utilty routine called from XGM to get the a tag value when the path to tag is specified
    --   The path starts from root element
    -- Arguments
    --   p_internal_control_num        input internal control number of xml message
    --   p_tag_path                    input tag path
    --   x_tag_value                   output tag value
    -- Notes
    --   No special notes

    PROCEDURE Get_tag_value_from_xml(
         p_internal_control_num    IN  NUMBER,
         p_tag_path                IN  VARCHAR2,
         x_tag_value               IN OUT NOCOPY VARCHAR2);


    -- Name
    --   TRUNCATE_STRING
    -- Purpose
    --   This is a utilty routine called from XGM to limit the length of input string
    -- Arguments
    --   p_internal_control_num        input internal control number of xml message
    --   p_tag_path                    input tag path
    --   x_tag_value                   output tag value
    -- Notes
    --   No special notes
    PROCEDURE TRUNCATE_STRING(
         p_instring in varchar2,
         p_numofchar in number,
         x_outstring out nocopy varchar2 );

END CLN_RN_UTILS;

 

/
