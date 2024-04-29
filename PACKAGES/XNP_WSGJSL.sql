--------------------------------------------------------
--  DDL for Package XNP_WSGJSL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WSGJSL" AUTHID CURRENT_USER as
/* $Header: XNPWSJSS.pls 120.0 2005/05/30 11:47:09 appldev noship $ */


   function OpenScript return varchar2;
   function CloseScript return varchar2;

   function OpenEvent(p_alias in varchar2, p_event in varchar2) return varchar2;
   function CloseEvent return varchar2;
   function CallEvent(p_alias in varchar2, p_event in varchar2) return varchar2;
   function CallValidate(p_alias in varchar2) return varchar2;

   function RtnNotNull return varchar2;
   function RtnCheckRange return varchar2;
   function RtnChkMaxLength return varchar2;
   function RtnChkNumPrecision return varchar2;
   function RtnChkNumScale return varchar2;
   function RtnStripMask return varchar2;
   function RtnToNumber return varchar2;
   function RtnMakeUpper return varchar2;
   function RtnChkConstraint return varchar2;
   function RtnRadioValue return varchar2;
   function RtnGetValue return varchar2;

   function RtnConcat return varchar2;
   function RtnInitCap return varchar2;
   function RtnInstr return varchar2;
   function RtnLength return varchar2;
   function RtnLower return varchar2;
   function RtnLPad return varchar2;
   function RtnLTrim return varchar2;
   function RtnNVL1 return varchar2;
   function RtnNVL2 return varchar2;
   function RtnReplace return varchar2;
   function RtnRound return varchar2;
   function RtnRPad return varchar2;
   function RtnRTrim return varchar2;
   function RtnSign return varchar2;
   function RtnSubstr return varchar2;
   function RtnTrunc return varchar2;
   function RtnUpper return varchar2;

   function CallCheckRange(p_ctl in varchar2, p_val in varchar2, p_lowval in number, p_hival in number, p_msg in varchar2) return varchar2;
   function CallChkMaxLength(p_ctl in varchar2, p_length in number, p_msg in varchar2) return varchar2;
   function CallChkNumPrecision(p_ctl in varchar2, p_val in varchar2, p_precision in number, p_msg in varchar2) return varchar2;
   function CallChkNumScale(p_ctl in varchar2, p_val in varchar2, p_scale in number, p_msg in varchar2) return varchar2;
   function CallChkConstraint(p_constraint in varchar, p_msg in varchar, p_indent in boolean) return varchar2;
   function CallMakeUpper(p_ctl in varchar2) return varchar2;
   function CallNotNull(p_ctl in varchar2, p_msg in varchar2) return varchar2;

   function StandardSubmit (set_Z_ACTION boolean default true) return varchar2;
   function VerifyDelete(p_msg in varchar2) return varchar2;

   function LOVButton(p_alias in varchar2, p_lovbut in varchar2) return varchar2;

   function DerivationField(p_name in varchar2, p_size in varchar2, p_value in varchar2) return varchar2;

   function AddCode(p_expr in varchar2) return varchar2;

end;

 

/
