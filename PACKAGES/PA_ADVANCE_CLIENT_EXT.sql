--------------------------------------------------------
--  DDL for Package PA_ADVANCE_CLIENT_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADVANCE_CLIENT_EXT" AUTHID CURRENT_USER AS
/*  $Header: PAAGADCS.pls 120.1 2006/11/21 05:35:33 rkchoudh noship $  */
/*#
 * The extension advance_required_check specifies that the advace required functionalty is allowed for a
 * agreement or it is not allowed
 * If this extension returns a valid value for the advance required flag, Oracle Projects uses that value as the value
 * of advance required flag
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Advance Required check
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
-------------------------------------------------------------------------------
-- Client extension
/*#
 * This extension specifies the advance required flag for the transaction being processed.
 * If this extension returns a valid value for the advance required flag,
 * Oracle Projects uses that value as the advance required flag instead of the default value
 * @param p_customer_id customer ID
 * @rep:paraminfo {@rep:required}
 * @param x_advance_flag Advance Required flag
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text .
 * @rep:paraminfo {@rep:required}
 * @param x_status  Status indicating whether an error
 * occurred. Valid values are:=0 Success <>0 Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Advance Required check.
 * @rep:compatibility S
 */


PROCEDURE advance_required(
        p_customer_id                   IN      NUMBER,
        x_advance_flag                  OUT     NOCOPY boolean,
        x_error_message                 OUT     NOCOPY Varchar2,
        x_status                        OUT     NOCOPY NUMBER
        );

--------------------------------------------------------------------------------

END PA_ADVANCE_CLIENT_EXT;

/
