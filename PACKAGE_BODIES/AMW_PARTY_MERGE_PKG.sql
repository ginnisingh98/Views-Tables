--------------------------------------------------------
--  DDL for Package Body AMW_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PARTY_MERGE_PKG" AS
/* $Header: amwhzmrb.pls 120.1 2006/06/08 15:56:03 yreddy noship $ */
/*===========================================================================*/


/*----------------------------------------------------------------------------+
 |
 | p_entity_name	Name of registered table/entity
 | p_from_id		Value of PK of the record being merged
 | x_to_id		Value of the PK of the record to which this record is mapped
 | p_from_fk_id		Value of the from ID (e.g. Party, Party Site, etc.) when merge is executed
 | p_to_fk_id		Value of the to ID (e.g. Party, Party Site, etc.) when merge is executed
 | p_parent_entity_name	Name of parent HZ table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
 | p_batch_id		ID of the batch
 | p_batch_party_id	ID of the batch and Party record
 |-----------------------------------------------------------------------------*/

  PROCEDURE party_merge
    (p_entity_name        in  varchar2,
     p_from_id            in  number,
     p_to_id              out nocopy number,
     p_from_fk_id         in  number,
     p_to_fk_id           in  number,
     p_parent_entity_name in  varchar2,
     p_batch_id           in  number,
     p_batch_party_id     in  number,
     p_return_status      out nocopy varchar2) is


  BEGIN

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_entity_name = 'AMW_ASSESSMENTS_B' THEN
        UPDATE amw_assessments_b
        SET assessment_owner_id = p_to_fk_id
        WHERE assessment_owner_id = p_from_fk_id;
    END IF;

    IF p_entity_name = 'AMW_CONSTRAINTS_B' THEN
        UPDATE amw_constraints_b
        SET entered_by_id = p_to_fk_id
        WHERE entered_by_id = p_from_fk_id;
    END IF;

    IF p_entity_name = 'AMW_CERTIFICATION_B' THEN
        UPDATE amw_certification_b
        SET certification_owner_id = p_to_fk_id
        WHERE certification_owner_id = p_from_fk_id;
    END IF;

    IF p_entity_name = 'AMW_VIOLATIONS' THEN
        UPDATE amw_violations
        SET requested_by_id = p_to_fk_id
        WHERE requested_by_id = p_from_fk_id;
    END IF;

    IF p_entity_name = 'AMW_AP_EXECUTIONS' THEN
        UPDATE amw_ap_executions
        SET executed_by = p_to_fk_id
        WHERE executed_by = p_from_fk_id;
    END IF;


  EXCEPTION
    when OTHERS then
      p_return_status :='FND_API.G_RET_STS_ERROR';

  END party_merge;


END AMW_PARTY_MERGE_PKG;

/
