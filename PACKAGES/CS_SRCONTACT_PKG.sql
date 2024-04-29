--------------------------------------------------------
--  DDL for Package CS_SRCONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SRCONTACT_PKG" AUTHID CURRENT_USER AS
/* $Header: cssrcps.pls 120.1 2005/12/22 15:49:17 spusegao noship $*/
--
PROCEDURE create_update
( p_incident_id     IN  NUMBER
, p_invocation_mode IN  VARCHAR2
, p_sr_update_date  IN  DATE
, p_sr_updated_by   IN  VARCHAR2
, p_sr_update_login IN  VARCHAR2
, p_contact_tbl     IN  CS_SERVICEREQUEST_PVT.contacts_table
, p_old_contact_tbl IN  CS_SERVICEREQUEST_PVT.contacts_table
, x_return_status   OUT NOCOPY VARCHAR2
) ;
PROCEDURE process
( p_mode                     IN  VARCHAR2
, p_incident_id              IN  NUMBER
, p_caller_type              IN  VARCHAR2
, p_customer_id              IN  NUMBER
, p_validation_mode          IN  NUMBER
, p_contact_tbl              IN  CS_SERVICEREQUEST_PVT.contacts_table
, x_contact_tbl              OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_old_contact_tbl          OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_primary_party_id         OUT NOCOPY NUMBER
, x_primary_contact_point_id OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
) ;
--------------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/15/05 smisra   Created
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Procedure Name : validate_contact
-- Parameters     :
-- IN             : p_caller_type     This is service request customer type.
--                                    It can be ORGANIZATION or PERSON
--                  p_new_contact_rec This record contains contact record passed
--                                    to service request API
--                  p_old_contact_rec This record containt value of contact
--                                    record being update. in case of insert
--                                    this record in NULL
-- OUT            : x_return_status   Indicates success or Error condition
--                                    encountered by procedure.
--
-- Description    : This procedure takes old and new value of contact being
--                  processed and validates it. Old value record is needed to
--                  determine if a particular attribute is changed or not.
--                  validation is performed on only changed attributes.
--                  in case of insert, all attributes that are not null are
--                  assumed to be changed attributes.
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/15/05 smisra   Created
--------------------------------------------------------------------------------
PROCEDURE validate_contact
( p_caller_type     IN         VARCHAR2
, p_customer_id     IN         NUMBER
, p_new_contact_rec IN         CS_SERVICEREQUEST_PVT.contacts_rec
, p_old_contact_rec IN         CS_SERVICEREQUEST_PVT.contacts_rec
, x_return_status   OUT NOCOPY VARCHAR2
);
--------------------------------------------------------------------------------
-- Procedure Name : process_g_miss
-- Parameters     :
-- IN             : x_new_contact_rec This record contains contact record passed
--                                    to service request API
--                  p_old_contact_rec This record containt value of contact
--                                    record being update. in case of insert
--                                    this record in NULL
-- OUT            : x_return_status   Indicates success or Error condition
--                                    encountered by procedure.
--
-- Description    : This procedure check new contact record and if any value if
--                  missing then it is set to it's value in old contact record.
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/15/05 smisra   Created
--------------------------------------------------------------------------------
/*
PROCEDURE process_g_miss
( p_mode            IN         VARCHAR2
, p_incident_id     IN         NUMBER
, p_new_contact_tbl IN         CS_SERVICEREQUEST_PVT.contacts_table
, x_new_contact_tbl OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_old_contact_tbl OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_table
, x_return_status   OUT NOCOPY VARCHAR2
);
*/

--------------------------------------------------------------------------------
-- Procedure Name : populate_cp_audit_rec
-- Parameters     :
-- IN             : p_sr_contact_point_id - Contact point identifier.
-- OUT            : x_cp_contact_rec This is a populated audit record.
--                : x_return_status   Indicates success or Error condition
--                                    encountered by procedure.
--                  x_msg_count
--                  x_msg_data
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 11/23/2005  spusegao created
--------------------------------------------------------------------------------

PROCEDURE Populate_CP_Audit_Rec
 (p_sr_contact_point_id  IN        NUMBER,
  x_sr_contact_rec      OUT NOCOPY CS_SERVICEREQUEST_PVT.contacts_rec,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2);


--------------------------------------------------------------------------------
-- Procedure Name :
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 04/27/05 smisra   Created
-- 11/23/05 spusegao added to the package spec so that this procedure is available for party merge routine.
--------------------------------------------------------------------------------
Procedure create_cp_audit
( p_sr_contact_point_id IN NUMBER
, p_incident_id     IN  NUMBER
, p_new_cp_rec IN  CS_SERVICEREQUEST_PVT.contacts_rec
, p_old_cp_rec IN  CS_SERVICEREQUEST_PVT.contacts_rec
, p_cp_modified_by    IN  NUMBER
, p_cp_modified_on    IN  DATE
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2);

END;

 

/
