--------------------------------------------------------
--  DDL for Package CZ_IB_TSO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IB_TSO_GRP" AUTHID CURRENT_USER AS
/*	$Header: czibtsos.pls 120.2 2005/06/30 12:54:17 skudryav ship $		*/

--
-- Removes returned config item by marking it with a special flags returned_flag
--

/*  Removes returned config item by marking it with a special flags returned_flag
* @param p_instance_hdr_id Identifies instance_hdr_id OF returned config item
* @param p_instance_rev_nbr Identifies instance_rev_nbr OF returned config item
* @param p_returned_config_item Identifies config_item_id OF returned config item
* @param p_locked_instance_rev_nbr  Identifies locked revision OF returned config item
* IF it IS NULL THEN this means that config item was NOT locked ( no pending orders WITH this item )
* @p_application_id - application Id OF caller ( if NULL then by default it's 542(IB))
* @p_config_eff_date - configuration effectivity date ( if NULL then by default it's SYSDATE )
* @param x_validation_status Returns either fnd_api.g_true IF configuration IS valid
* OR fnd_api.g_false IF configuration IS NOT valid
* @param x_return_status Returns one OF three VALUES indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS IF no errors occurred
 * FND_API.G_RET_STS_ERROR IF AT LEAST one error occurred
 * FND_API.G_RET_STS_UNEXP_ERROR IF AT LEAST one unexpected error occurred
 * @param x_msg_count Indicates how many messages exist ON ERROR_HANDLER
 * message stack upon completion OF processing.
 * @param x_msg_data IF exactly one message EXISTS ON ERROR_HANDLER
 * message stack upon completion OF processing, this parameter contains
 * that message.
 *
 * @rep:scope PUBLIC
 * @rep:lifecycle active
 * @rep:displayname Remove Returned Config Item
 */
PROCEDURE remove_Returned_Config_Item
(
 p_instance_hdr_id           IN  NUMBER,
 p_instance_rev_nbr          IN  NUMBER,
 p_returned_config_item_id   IN  NUMBER,
 p_locked_instance_rev_nbr   IN  NUMBER,
 p_application_id            IN  NUMBER,
 p_config_eff_date           IN  DATE,
 x_validation_status         OUT NOCOPY VARCHAR2,
 x_return_status             OUT NOCOPY VARCHAR2,
 x_msg_count                 OUT NOCOPY NUMBER,
 x_msg_data                  OUT NOCOPY VARCHAR2
 );

END CZ_IB_TSO_GRP;

 

/
