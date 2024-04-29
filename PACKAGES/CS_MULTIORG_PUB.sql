--------------------------------------------------------
--  DDL for Package CS_MULTIORG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_MULTIORG_PUB" AUTHID CURRENT_USER as
/* $Header: csxpmois.pls 120.5 2006/06/26 21:13:44 aseethep ship $ */
/*#
 * This public interface for the charges functionality in Oracle Service, determines the default operating
 * unit for a charge line based on multi-org rules setup.
 *
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Service Charges
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CS_SERVICE_CHARGE
 */
/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that the interfaces
      defined in this package appears in the integration repository.
****/

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_OrgId
--   Type    :  Public
--   Purpose :  This public API is to get the MutliOrg id.
--              The implementation will be a wrapper on CS_MultiOrg_PVT.Get_OrgId private API.
--   Pre-Req :
--   Parameters:
--       p_api_version          IN                  NUMBER      Required
--       p_init_msg_list        IN                  VARCHAR2
--       p_commit               IN                  VARCHAR2
--       p_validation_level     IN                  NUMBER
--       x_return_status        OUT     NOCOPY      VARCHAR2
--       x_msg_count            OUT     NOCOPY      NUMBER
--       x_msg_data             OUT     NOCOPY      VARCHAR2
--       p_incident_id          IN                  NUMBER      Required
--       x_org_id			    OUT	    NOCOPY	    NUMBER,
--       x_profile			    OUT 	NOCOPY	    VARCHAR2

--   Version : Current version 1.0
--   End of Comments
--

/*#
 * Get OrgID (Version 1.0) can be used to determine the default org_id (i.e operating unit) based on the
 * multi-org rules setup.
 *
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Multiorg
 * @rep:primaryinstance
*/

/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that Get_OrgId API
      appears in the integration repository.
****/


PROCEDURE Get_OrgId (
    p_api_version		IN              NUMBER,
    p_init_msg_list		IN 	            VARCHAR2,
    p_commit			IN			    VARCHAR2,
    p_validation_level	IN	            NUMBER,
    x_return_status		OUT     NOCOPY 	VARCHAR2,
    x_msg_count			OUT 	NOCOPY 	NUMBER,
    x_msg_data			OUT 	NOCOPY 	VARCHAR2,
    p_incident_id		IN	            NUMBER,
    x_org_id			OUT	    NOCOPY	NUMBER,
    x_profile			OUT 	NOCOPY	VARCHAR2
);

End CS_MultiOrg_PUB;

 

/
