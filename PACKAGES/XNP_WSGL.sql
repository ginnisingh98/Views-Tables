--------------------------------------------------------
--  DDL for Package XNP_WSGL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WSGL" AUTHID CURRENT_USER as
/* $Header: XNPWSGLS.pls 120.2 2006/02/13 07:58:58 dputhiye ship $ */


--------------------------------------------------------------------------------
-- Declare constants for use in Layout procedures
   LAYOUT_TABLE      constant number(1) := 1;
   LAYOUT_PREFORMAT  constant number(1) := 2;
   LAYOUT_BULLET     constant number(1) := 3;
   LAYOUT_NUMBER     constant number(1) := 4;
   LAYOUT_CUSTOM     constant number(1) := 5;
   LAYOUT_WRAP       constant number(1) := 6;

   MENU_LONG         constant number(1) := 1;
   MENU_SHORT        constant number(1) := 2;

   TYPE_CHAR         constant number(1) := 1;
   TYPE_CHAR_UPPER   constant number(1) := 2;
   TYPE_DATE         constant number(1) := 3;
   TYPE_NUMBER       constant number(1) := 4;

--------------------------------------------------------------------------------
-- Declare constant for Max number of rows which can be returned
   MAX_ROWS          constant number(4) := 1000;

--------------------------------------------------------------------------------
-- Declare types used in Domain Validation

   DV_TEXT     constant number(1) := 1;
   DV_CHECK    constant number(1) := 2;
   DV_RADIO    constant number(1) := 3;
   DV_LIST     constant number(1) := 4;

   type typString240Table is table of varchar2(240)
                          index by binary_integer;

   type typDVRecord is record
        (ColAlias    varchar2(30) := null,
         Initialised boolean      := false,
         ControlType number(1)    := DV_TEXT,
         DispWidth   number(5)    := 30,
         DispHeight  number(5)    := 1,
         MaxWidth    number(5)    := 30,
         UseMeanings boolean      := false,
         ColOptional boolean      := false,
         NumOfVV     integer      := 0,
         Vals typString240Table,
         Meanings typString240Table,
         Abbreviations typString240Table);

   EmptyStringTable  typString240Table;
--------------------------------------------------------------------------------
-- Declare types used in building controls
   CTL_READONLY     constant number(1) := 1;
   CTL_UPDATABLE    constant number(1) := 2;
   CTL_INSERTABLE   constant number(1) := 3;
   CTL_QUERY        constant number(1) := 4;

--------------------------------------------------------------------------------
-- Declare constants for form status
   FORM_STATUS_OK      constant number(1) := 0;
   FORM_STATUS_ERROR   constant number(1) := 1;
   FORM_STATUS_INS     constant number(1) := 2;
   FORM_STATUS_UPD     constant number(1) := 3;

--------------------------------------------------------------------------------
-- Declare constants message types
   MESS_INFORMATION    constant number(1) := 1;
   MESS_SUCCESS        constant number(1) := 2;
   MESS_WARNING        constant number(1) := 3;
   MESS_ERROR          constant number(1) := 4;
   MESS_ERROR_QRY      constant number(1) := 5;
   MESS_EXCEPTION      constant number(1) := 6;

--------------------------------------------------------------------------------
-- Declare WebServer Generator Library procedures and functions

   function IsSupported (feature in varchar2) return boolean;

   procedure LayoutOpen(p_layout_style in number,
                        p_border in boolean default false,
                        p_custom_bullet in varchar2 default null);

   procedure LayoutClose;

   procedure LayoutRowStart(p_valign in varchar2 default null);

   procedure LayoutRowEnd;

   procedure LayoutHeader(p_width in number,
                          p_align in varchar2,
                          p_title in varchar2);

   procedure LayoutData(p_text in varchar2);
   procedure LayoutData(p_date in date);
   procedure LayoutData(p_number in number);

   procedure DefinePageHead(p_title in varchar2 default null,
                            p_bottomframe in boolean default false);

   procedure OpenPageHead(p_title in varchar2 default null,
                          p_bottomframe in boolean default false);

   procedure ClosePageHead;

   procedure OpenPageBody(p_center in boolean default false,
                          p_attributes in varchar2 default null);

   procedure ClosePageBody;

   function  InBottomFrame return boolean;

   function  Preformat(p_text in varchar2) return varchar2;

   procedure DefaultPageCaption(p_caption in varchar2 default null,
                                p_headlevel in number default null);

   procedure BuildWhere(p_field1   in varchar2,
                        p_field2   in varchar2,
                        p_sli      in varchar2,
                        p_datatype in number,
                        p_where    in OUT NOCOPY varchar2,
                        p_date_format in varchar2 default null);

   procedure BuildWhere(p_field    in varchar2,
                        p_sli      in varchar2,
                        p_datatype in number,
                        p_where    in OUT NOCOPY varchar2,
                        p_date_format in varchar2 default null,
                        p_caseinsensitive in boolean default true);

   procedure BuildWhere(p_field    in typString240Table,
                        p_sli      in varchar2,
                        p_datatype in number,
                        p_where    in OUT NOCOPY varchar2,
                        p_date_format in varchar2 default null);

   function SearchComponents(p_search in varchar2,
                             p_uu in OUT NOCOPY varchar2,
                             p_ul in OUT NOCOPY varchar2,
                             p_lu in OUT NOCOPY varchar2,
                             p_ll in OUT NOCOPY varchar2) return number;

   procedure NavLinks(p_style in number default null,
                      p_caption in varchar2 default null,
                      p_menu_level in number default 0,
                      p_proc in varchar2 default null,
                      p_target in varchar2 default '_top');

   function  TablesSupported return boolean;

   procedure Info(p_full in boolean default true,
                  p_app in varchar2 default null,
                  p_mod in varchar2 default null);

   procedure EmptyPage(p_attributes in varchar2 default null);
   function  EmptyPageURL(p_attributes in varchar2 default null) return varchar2;

   procedure SubmitButton(p_name in varchar2,
                          p_title in varchar2,
                          p_type in varchar2,
                          buttonJS in varchar2 default null);

   procedure RecordListButton(p_reqd in boolean,
                  p_name in varchar2,
                              p_title in varchar2,
                              p_mess in varchar2 default null,
                  p_dojs in boolean default false,
            buttonJS in varchar2 default null
                  );

   function  CountHits(
             P_SQL in varchar2) return number;

   procedure LoadDomainValues(
             P_REF_CODE_TABLE in varchar2,
             P_DOMAIN in varchar2,
             P_DVREC in OUT NOCOPY typDVRecord);

   function ValidDomainValue(
            P_DVREC in typDVRecord,
            P_VALUE in OUT NOCOPY varchar2) return boolean;

   function DomainMeaning(
            P_DVREC in typDVRecord,
            P_VALUE in varchar2) return varchar2;

   function DomainValue(
            P_DVREC in typDVRecord,
            P_MEANING in varchar2) return varchar2;

   function DomainValue(
            P_DVREC in typDVRecord,
            P_MEANING in typString240Table) return typString240Table;

   function BuildDVControl(
            P_DVREC in typDVRecord,
            P_CTL_STYLE in number,
            P_CURR_VAL in varchar2 default null,
            p_onclick in boolean default false,
            p_onchange in boolean default false,
            p_onblur in boolean default false,
            p_onfocus in boolean default false,
            p_onselect in boolean default false) return varchar2;

   function BuildTextControl(
            p_alias in varchar2,
            p_size in varchar2 default null,
            p_height in varchar2 default null,
            p_maxlength in varchar2 default null,
            p_value in varchar2 default null,
            p_onclick in boolean default false,
            p_onchange in boolean default false,
            p_onblur in boolean default false,
            p_onfocus in boolean default false,
            p_onselect in boolean default false) return varchar2;

   function BuildQueryControl(
            p_alias in varchar2,
            p_size in varchar2 default null,
            p_range in boolean default false,
            p_onclick in boolean default false,
            p_onchange in boolean default false,
            p_onblur in boolean default false,
            p_onfocus in boolean default false,
            p_onselect in boolean default false) return varchar2;

   function BuildDerivationControl(p_name in varchar2,
                                   p_size in varchar2,
                                   p_value in varchar2,
                                   p_onclick in boolean default false,
                                   p_onblur in boolean default false,
                                   p_onfocus in boolean default false,
                                   p_onselect in boolean default false) return varchar2;

   procedure HiddenField(p_paramname in varchar2,
                         p_paramval in varchar2);

   procedure HiddenField(p_paramname in varchar2,
                         p_paramval in typString240Table);

   procedure DisplayMessage(p_type in number,
                            p_mess in varchar2,
                            p_title in varchar2 default null,
                            p_attributes in varchar2 default null,
                            p_location in varchar2 default null,
                            p_context in varchar2 default null,
                            p_action in varchar2 default null);

   procedure StoreErrorMessage(p_mess in varchar2);

   function MsgGetText(p_MsgNo in number,
                       p_DfltText in varchar2 default null,
                       p_Subst1 in varchar2 default null,
                       p_Subst2 in varchar2 default null,
                       p_Subst3 in varchar2 default null,
                       p_LangId in number default null) return varchar2;

   function EscapeURLParam(p_param in varchar2 ) return varchar2;

   function GetUser return varchar2;
--   pragma restrict_references(GetUser, WNDS, WNPS);

   procedure RegisterURL(p_url in varchar2);

   procedure AddURLParam(p_paramname in varchar2,
                         p_paramval in varchar2);

   procedure AddURLParam(p_paramname in varchar2,
                         p_paramval in typString240Table);

   procedure RefreshURL;

   function NotLowerCase return boolean;

   function ExternalCall(p_proc in varchar2) return boolean;

   function CalledDirect(p_proc in varchar2) return boolean;

   procedure StoreURLLink(p_level in number,
                          p_caption in varchar2,
                          p_open in boolean default true,
                          p_close in boolean default true);

   procedure ReturnLinks(p_levels in varchar2, p_style in number);

   function Checksum(p_buff in varchar2) return number;
   function ValidateChecksum(p_buff in varchar2, p_checksum in varchar2) return boolean;

   -- R2.1 Backward compatibility
   function EscapeURLParam(p_param in varchar2,
                           p_space in boolean default true,
                           p_plus in boolean default true,
                           p_percent in boolean,
                           p_doublequote in boolean default true,
                           p_hash in boolean default true,
                           p_ampersand in boolean ) return varchar2;


   -- R1.3 Backward compatibility
   procedure RowContext(p_context in varchar2);

   procedure PageHeader(p_title in varchar2,
                        p_header in varchar2,
                        p_background in varchar2 default null,
                        p_center in boolean default false);

   procedure PageFooter;

   function  MAX_ROWS_MESSAGE return varchar2;

end;

 

/
