--------------------------------------------------------
--  DDL for Package PQH_AME_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_AME_APPROVALS" AUTHID CURRENT_USER AS
/* $Header: pqameapr.pkh 120.0 2005/05/29 01:24:06 appldev noship $ */
--
--
   PROCEDURE initialize_ame (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     );

   PROCEDURE check_final_approver (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     );

   PROCEDURE find_next_approver (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     );


 PROCEDURE mark_elctbl_chc_approved (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     );

 PROCEDURE mark_elctbl_chc_rejected (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     );

 PROCEDURE unmark_wf_flag_for_elctbl_chc (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     );


END; -- Package Specification PQH_AME_APPROVALS

 

/
