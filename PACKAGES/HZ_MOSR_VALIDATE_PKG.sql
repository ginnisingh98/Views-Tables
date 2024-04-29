--------------------------------------------------------
--  DDL for Package HZ_MOSR_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MOSR_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHOSRVS.pls 120.2 2005/10/30 04:21:20 appldev noship $ */

PROCEDURE VALIDATE_ORIG_SYS_ENTITY_MAP (
    p_create_update_flag                IN	VARCHAR2,
    p_orig_sys_entity_map_rec           IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    x_return_status                     IN OUT NOCOPY VARCHAR2

);

PROCEDURE VALIDATE_ORIG_SYS_REFERENCE (
    p_create_update_flag                    IN     VARCHAR2,
    p_orig_sys_reference_rec               IN     HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2

);

function get_orig_system_ref_count(p_orig_system in varchar2,p_orig_system_reference in varchar2, p_owner_table_name in varchar2) return varchar2;

PROCEDURE VALIDATE_ORIG_SYSTEM (
    p_create_update_flag                    IN     VARCHAR2,
    p_orig_sys_rec               IN HZ_ORIG_SYSTEM_REF_PVT.ORIG_SYS_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2

);

END HZ_MOSR_VALIDATE_PKG;

 

/
