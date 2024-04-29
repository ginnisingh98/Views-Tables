--------------------------------------------------------
--  DDL for Package WIP_UNRELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_UNRELEASE" AUTHID CURRENT_USER AS
 /* $Header: wippunrs.pls 120.1.12010000.2 2008/09/12 00:28:45 ankohli ship $ */

/* UNRELEASE
 DESCRIPTION:
   This procedure checks to make sure no charges have been made against the
   job or schedule, and then updates all operation quantities to 0.  Note that
   the form that calls this procedure should null out the date_released
   field, as this procedure does not do that.
 PARAMETERS:
   No validation is performed on the input parameters.
*/

  PROCEDURE UNRELEASE
    (x_org_id IN NUMBER,
     x_wip_id IN NUMBER,
     x_rep_id IN NUMBER DEFAULT -1,
     x_line_id IN NUMBER DEFAULT -1,
     x_ent_type IN NUMBER);


 /* wrapper over procedure UNRelease()
 This also updates the status of job to UNRelease in the databse at the end
 */
  PROCEDURE UNRELEASE_MES_WRAPPER
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER
    );

    FUNCTION VERIFY_WPB     /*Added function for bug 7325661 (FP 6721407)*/
     ( x_org_id IN NUMBER,
       x_wip_id IN NUMBER,
       x_rep_id IN NUMBER DEFAULT NULL
     ) RETURN NUMBER;

END WIP_UNRELEASE;

/
