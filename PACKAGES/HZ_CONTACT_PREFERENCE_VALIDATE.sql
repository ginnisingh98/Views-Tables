--------------------------------------------------------
--  DDL for Package HZ_CONTACT_PREFERENCE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_PREFERENCE_VALIDATE" AUTHID CURRENT_USER AS
/*$Header: ARH2CTVS.pls 115.1 2002/11/21 05:17:01 sponnamb noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

PROCEDURE validate_contact_preference (
    p_create_update_flag                    IN     VARCHAR2,
    p_contact_preference_rec                IN     HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE,
    p_rowid                                 IN     ROWID,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);


END HZ_CONTACT_PREFERENCE_VALIDATE;

 

/
