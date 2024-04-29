--------------------------------------------------------
--  DDL for Package ITG_X_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_X_UTILS" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgxutls.pls 120.2 2006/02/16 23:00:27 bsaratna noship $
 * CVS:  itgxutls.pls,v 1.19 2003/02/05 23:05:06 klai Exp
 */

  /* Who are we? */
  c_app_short_name      CONSTANT VARCHAR2(5)  := 'ITG';
  c_application_id      CONSTANT NUMBER       := 230;
  c_user_id             CONSTANT NUMBER       := 3;
  c_resp_id             CONSTANT NUMBER       := 20707;
  c_resp_appl_id        CONSTANT NUMBER       := 201;

  /* Collaboration points. */
  c_coll_pt             CONSTANT VARCHAR2(30) := 'OIPC';
  c_final_coll_pt       CONSTANT VARCHAR2(30) := 'OIPC_FINAL';
  c_xmlg_coll_pt        CONSTANT VARCHAR2(30) := 'XML_GATEWAY';

  /* Outbound event constants/values */
  c_event_name          CONSTANT VARCHAR2(30) := 'oracle.apps.itg.outbound';
  g_event_key_pfx                VARCHAR2(60);
  g_local_system                 wf_systems.name%TYPE;
  c_correlation_id      CONSTANT VARCHAR2(10) := 'ITG_CID';

  /* Trading pertner info. */
  c_party_type          CONSTANT VARCHAR2(1)  := 'I';
  c_party_site_name     CONSTANT VARCHAR2(30) := 'OIPC Default TP';
  g_party_id                     VARCHAR2(40);
  g_party_site_id                VARCHAR2(40);

  /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE
   * Show package initialization/setup status in reference to possibly
   * missing data in hr_locations_all (or any other problem at package
   * load time).
   */
  g_initialized                  BOOLEAN      := FALSE;

  /*
  ** Given an Address Style, return the Region with the
  ** County name or equivalent
  */
  FUNCTION getCounty (
    addrStyle IN  VARCHAR2,
    regionOne IN  VARCHAR2,
    regionTwo IN  VARCHAR2
  ) RETURN VARCHAR2;
  PRAGMA restrict_references( getCounty, WNDS );

  /*
  ** Which segment in the p_idFlexNum is the p_flexQualifierName segment?
  ** Returns the fnd_id_flex_segments.application_column_name value.
  */
  FUNCTION getFlexQualifierSegment (
    p_idFlexNum         number,
    p_flexQualifierName varchar2
  ) return varchar2;
  PRAGMA restrict_references ( getFlexQualifierSegment, WNDS );

  /*
  ** get_inventory_org_id is used to get the inventory_organization_id
  ** given the org_id using the financials_system_params_all table
  */

  FUNCTION get_inventory_org_id (p_org_id NUMBER)
    RETURN NUMBER;
  PRAGMA restrict_references( get_inventory_org_id, WNDS );

  /*
  ** Given a po_req_distribution_id, return the segment1
  */
  function getRequistnid ( poReqDistId IN Number ) return varchar2;
  PRAGMA restrict_references( getRequistnid, WNDS );

  /*
  ** Given a po_req_distribution_id, return the line_num from po_requisition_lines_all
  */
  FUNCTION getReqLineNum ( poReqDistId IN Number )
    RETURN varchar2;
  PRAGMA restrict_references( getReqLineNum, WNDS );

  /*
  ** Given an Address Style, return the Region with the
  ** State/Province name or equivalent
  */
  FUNCTION getState (
    addrStyle IN  VARCHAR2,
    regionOne IN  VARCHAR2,
    regionTwo IN  VARCHAR2
  ) RETURN VARCHAR2;
  PRAGMA restrict_references( getState, WNDS );

  /*
  ** getTaxId looks up a TIN or VRN for a given US or non-US
  ** company.  Returns a NULL if no ID number found.
  */
  FUNCTION getTaxId (
    country    IN varchar2,
    orgId      IN number,
    orgName    IN varchar2,
    orgUnit    IN number,
    invOrg     IN number
  ) RETURN VARCHAR2;

  /*
  ** Return a concatenated segment string with
  ** appropriate delimiter for the given flexfield
  */
  FUNCTION SegString (
    appId     IN NUMBER,
    flexCode  IN VARCHAR2,
    flexNum   IN NUMBER,
    segment1  IN VARCHAR2,         segment2  IN VARCHAR2,
    segment3  IN VARCHAR2,         segment4  IN VARCHAR2 := NULL,
    segment5  IN VARCHAR2 := NULL, segment6  IN VARCHAR2 := NULL,
    segment7  IN VARCHAR2 := NULL, segment8  IN VARCHAR2 := NULL,
    segment9  IN VARCHAR2 := NULL, segment10 IN VARCHAR2 := NULL,
    segment11 IN VARCHAR2 := NULL, segment12 IN VARCHAR2 := NULL,
    segment13 IN VARCHAR2 := NULL, segment14 IN VARCHAR2 := NULL,
    segment15 IN VARCHAR2 := NULL, segment16 IN VARCHAR2 := NULL,
    segment17 IN VARCHAR2 := NULL, segment18 IN VARCHAR2 := NULL,
    segment19 IN VARCHAR2 := NULL, segment20 IN VARCHAR2 := NULL,
    segment21 IN VARCHAR2 := NULL, segment22 IN VARCHAR2 := NULL,
    segment23 IN VARCHAR2 := NULL, segment24 IN VARCHAR2 := NULL,
    segment25 IN VARCHAR2 := NULL, segment26 IN VARCHAR2 := NULL,
    segment27 IN VARCHAR2 := NULL, segment28 IN VARCHAR2 := NULL,
    segment29 IN VARCHAR2 := NULL, segment30 IN VARCHAR2 := NULL
  )  RETURN VARCHAR2;
  PRAGMA restrict_references( segString, WNDS );

  /*
  ** Returns the sign of a number
  */
  FUNCTION signOf ( anyNumber IN Number )
    RETURN varchar2;
  PRAGMA restrict_references( signOf, WNDS );

  /*
  ** sumPoLineLocs summarizes the quantity*price_override
  ** from po_line_locations_all for the given po_header_id
  **
  ** Taken from Po_Ip_Oagxml_Pkg.
  */
  FUNCTION sumPoLineLocs (
    poHeaderId IN Number,
    poRelease  IN Number := null
  ) RETURN number;
  PRAGMA restrict_references( sumPoLineLocs, WNDS );

  /*
  ** sumPoLineLocs summarizes the quantity*price_override
  ** from po_line_locations_all for the given po_header_id
  **
  */
  FUNCTION sumReqLines ( reqHeaderId IN NUMBER )
    RETURN NUMBER;
  PRAGMA restrict_references( sumReqLines, WNDS );

  FUNCTION getAttachments(p_table_name VARCHAR2,
                          p_type       VARCHAR2,
                          p_id         NUMBER )
   RETURN VARCHAR2;

  FUNCTION isPoLineApproved(v_po_line_id in Number)
    RETURN NUMBER;
  PRAGMA restrict_references( isPoLineApproved, WNDS );

  PROCEDURE addCBODDescMsg(p_msg_app      IN VARCHAR2,
				   p_msg_code     IN VARCHAR2,
                           p_token_vals   IN VARCHAR2 := NULL,
                           p_translatable IN BOOLEAN  := TRUE,
                           p_reset        IN BOOLEAN  := FALSE);

  FUNCTION getCBODDescMsg(p_reset IN BOOLEAN := FALSE) RETURN VARCHAR2;

  FUNCTION translateCBODDescMsg(p_msg_list IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE getTextAttachments(p_table_name VARCHAR2,
                           p_id         NUMBER,
				   x_pointernal OUT NOCOPY VARCHAR2,
                           x_misc       OUT NOCOPY VARCHAR2,
                           x_approver   OUT NOCOPY VARCHAR2,
                           x_buyer      OUT NOCOPY VARCHAR2,
                           x_payables   OUT NOCOPY VARCHAR2,
                           x_reciever   OUT NOCOPY VARCHAR2,
                           x_vendor     OUT NOCOPY VARCHAR2);


END;

 

/
