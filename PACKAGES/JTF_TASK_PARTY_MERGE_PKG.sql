--------------------------------------------------------
--  DDL for Package JTF_TASK_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_PARTY_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: jtftkpms.pls 115.8 2002/12/04 02:13:19 cjang ship $ */
--/**==================================================================*
--  Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA
--                       All rights reserved.
--+====================================================================+
-- Start of comments
--	API name 	: JTF_TASK_PARTY_MERGE_PKG
--	Type		: Public.
--	Function	: Party merge package. Merges duplicate parties
--			  in TASKs tables.
--	Pre-reqs	: None.
--	Parameters	:
--     	 name                 direction  type
--     	----                  ---------  ----
--     	p_entity_name         	IN	VARCHAR2 - Name of the entity that is being merged
--     	p_from_id             	IN	NUMBER   - Id of the record that is being merged
--     	x_to_id               	OUT	NUMBER   - Id of the record under the new parent
--                                      	   that its merged to
--     	p_from_fk_id          	IN	NUMBER   - Id of the Old Parent
--     	p_to_fk_id            	IN	NUMBER   - Id of the New Parent
--     	p_parent_entity_name  	IN	VARCHAR2 - Parent entity name
--     	p_batch_id            	IN	NUMBER   - Id of the Batch
--     	p_batch_party_id      	IN	NUMBER   - Id of the batch and party record

--     	x_return_status       	OUT	VARCHAR2 - Return the status of the procedure
--
--	All of the parameters are required
--
--
--	Version	: 1.0
-------------------------------------------------------------------------------------------
--				History
-------------------------------------------------------------------------------------------
--	16-FEB-01	tivanov		Created.
---------------------------------------------------------------------------------
--
-- End of comments
-------------------------------------------------------------------------------------------
--
-- The following foreign keys will be merged:
--		jtf_tasks_b.customer_id
--		jtf_tasks_b.address_id
--		jtf_tasks_b.source_object_id
--		jtf_tasks_b.source_object_name
--		jtf_task_audits_b.new_customer_id
--		jtf_task_audits_b.old_customer_id
--		jtf_task_audits_b.new_address_id
--		jtf_task_audits_b.old_address_id
--		jtf_task_audits_b.new_source_object_id
--		jtf_task_audits_b.old_source_object_id
--		jtf_task_audits_b.new_source_object_name
--		jtf_task_audits_b.old_source_object_name
--		jtf_task_references_b.object_id
--		jtf_task_references_b.object_name
--		jtf_task_contacts.contact_id
--		jtf_task_phones.phone_id
-------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_MERGE_PARTY -  Performs party ids  merge in JTF_TASKS_B table.
--		Updates CUSTOMER_ID column  with the merged to party_id value
--		e.g. if party_id 1000 got merged to party_id  2000 then, we have to update
--		all records with customer_id = 1000 to 2000.
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_PARTY(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_MERGE_ADDRESS - Performs party_site merge in JTF_TASKS_B table.
--		Updates JTF_TASKS_B.ADDRESS_ID column with the merged to party_site_id
--		e.g. if party_site_id 1111 got merged to party_site_id  2222 then,
--		we have to update all records with address_id = 1111 to 2222
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_ADDRESS(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_MERGE_SOURCE_OBJECT - Performs party ids merge in JTF_TASKS_B table.
--		Updates SOURCE_OBJECT_ID, SOURCE_OBJECT_NAME columns.
--		The SOURCE_OBJECT_ID, SOURCE_OBJECT_NAME , SOURCE_OBJECT_TYPE_CODE  data
--		in JTF_TASKS table is dynamically retrieved from JTF_OBJECTS table.
--		The source object could be of type 'Party', 'Person (Party)' ,
--		'Relationships(Party)' , 'Party Site' etc. The merge procedure updates
--		JTF_TASKS_B.SOURCE_OBJECT_ID and JTF_TASKS_B.SOURCE_OBJECT_NAME columns
--		with the merged to respectively party_id and party_name in all records
--		that have SOURCE_OBJECT_TYPE_CODE related to HZ_PARTY.PARTY_ID.
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_SOURCE_OBJECT(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_AUDIT_MERGE_NEW_S_OBJECT - Performs party ids merge in
--		JTF_TASK_AUDITS_B table.
--		Updated columns - NEW_SOURCE_OBJECT_ID , NEW_SOURCE_OBJECT_NAME.
--		The NEW_SOURCE_OBJECT_ID, NEW_SOURCE_OBJECT_NAME ,
--		NEW_SOURCE_OBJECT_TYPE_CODE  columns in JTF_TASK_AUDITS_B table
--		are copies of the corresponding columns in JTF_TASKS_B table which
--		are dynamically retrieved from JTF_OBJECTS table. The source object
--		could be of type 'Party', 'Person (Party)' , 'Relationships(Party)',
--		'Party Site' etc. The merge procedure updates
--		JTF_TASK_AUDITS_B.NEW_SOURCE_OBJECT_ID and
--		JTF_TASK_AUDITS_B.SOURCE_OBJECT_NAME columns with the merged to
--		respectively party_id and party_name in all records that have
--		NEW_SOURCE_OBJECT_TYPE_CODE related to HZ_PARTY.PARTY_ID.
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_NEW_S_OBJECT(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);


------------------------------------------------------------------------------------------
-- Procedure: 	TASK_AUDIT_MERGE_OLD_S_OBJECT - Performs party ids merge in
--		JTF_TASK_AUDITS_B table.
--		Updated columns - OLD_SOURCE_OBJECT_ID , OLD_SOURCE_OBJECT_NAME.
--		The OLD_SOURCE_OBJECT_ID, OLD_SOURCE_OBJECT_NAME ,
--		OLD_SOURCE_OBJECT_TYPE_CODE  columns in JTF_TASK_AUDITS_B table are copies
--		of the corresponding columns in JTF_TASKS_B table which are dynamically
--		retrieved from JTF_OBJECTS table. The source object could be of type
--		'Party', 'Person (Party)' , 'Relationships(Party)', 'Party Site' etc.
--		The merge procedure updates JTF_TASK_AUDITS_B.OLD_SOURCE_OBJECT_ID
--		and JTF_TASK_AUDITS_B.SOURCE_OBJECT_NAME columns with the merged
--		to respectively party_id and party_name in all records that have
--		OLD_SOURCE_OBJECT_TYPE_CODE related to HZ_PARTY.PARTY_ID.
------------------------------------------------------------------------------------------


PROCEDURE TASK_AUDIT_MERGE_OLD_S_OBJECT(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_AUDIT_MERGE_NEW_CUSTOMER - Performs party ids  merge in
--		JTF_TASK_AUDITS_B table.
--		Updates NEW_CUSTOMER_ID column  with the merged to party_id value e.g.
--		if party_id 1000 got merged to party_id  2000 then, we have to update
--		all records with new_customer_id = 1000 to 2000.
------------------------------------------------------------------------------------------


PROCEDURE TASK_AUDIT_MERGE_NEW_CUSTOMER(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_AUDIT_MERGE_OLD_CUSTOMER - Performs party ids  merge in
--		JTF_TASK_AUDITS_B table.
--		Updates OLD_CUSTOMER_ID column  with the merged to party_id value
--		e.g. if party_id 1000 got merged to party_id  2000 then, we have
--		to update all records with old_customer_id = 1000 to 2000.
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_OLD_CUSTOMER(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_AUDIT_MERGE_NEW_ADDRESS - Performs party_site merge in
--		JTF_TASK_AUDITS_B table. Updated columns - NEW_ADDRESS_ID.
--		Updates JTF_TASK_AUDITS_B.NEW_ADDRESS_ID column with the merged
--		to party_site_id e.g. if party_site_id 1111 got merged
--		to party_site_id  2222 then, we have to update all records
--		with new_address_id = 1111 to 2222
------------------------------------------------------------------------------------------

PROCEDURE TASK_AUDIT_MERGE_NEW_ADDRESS(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_AUDIT_MERGE_OLD_ADDRESS - Performs party_site merge in
--		JTF_TASK_AUDITS_B table.
--		Updates JTF_TASK_AUDITS_B.OLD_ADDRESS_ID column with the merged
--		to party_site_id e.g. if party_site_id 1111 got merged
--		to party_site_id  2222 then, we have to update all records
--		with old_address_id = 1111 to 2222
------------------------------------------------------------------------------------------
PROCEDURE TASK_AUDIT_MERGE_OLD_ADDRESS(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_REF_MERGE_PARTY_OBJECT - Performs party ids  merge in
--		JTF_TASK_REFERENCES_B table. Updated columns - OBJECT_ID, OBJECT_NAME
--		The OBJECT_ID, OBJECT_NAME , OBJECT_TYPE_CODE  data in JTF_TASK_REFEENCES_B
--		table is dynamically retrieved from JTF_OBJECTS table. The source object
--		could be of type 'Party', 'Person (Party)' , 'Relationships(Party)' ,
--		'Party Site' etc. The merge procedure updates JTF_TASK_REFEENCES_B.
--		OBJECT_ID and JTF_TASK_REFEENCES_B. OBJECT_NAME columns with the merged
--		to respectively party _id and party_name in all records that have
--		SOURCE_OBJECT_TYPE_CODE related to HZ_PARTY_SITES.PARTY_ ID.
------------------------------------------------------------------------------------------

PROCEDURE TASK_REF_MERGE_PARTY_OBJECT(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_REF_MERGE_PSITE_OBJECT - Performs party site ids  merge in
--		JTF_TASK_REFERENCES_B table.
--		The OBJECT_ID, OBJECT_NAME , OBJECT_TYPE_CODE  data in JTF_TASK_REFEENCES_B
--		table is dynamically retrieved from JTF_OBJECTS table. The source object
--		could be of type 'Party', 'Person (Party)' , 'Relationships(Party)' ,
--		'Party Site' etc. The merge procedure updates JTF_TASK_REFEENCES_B.
--		OBJECT_ID and JTF_TASK_REFEENCES_B. OBJECT_NAME columns with the merged
--		to respectively party_site_id and party_site_name in all records that have
--		SOURCE_OBJECT_TYPE_CODE related to HZ_PARTY_SITES.PARTY_SITE_ID.
------------------------------------------------------------------------------------------

PROCEDURE TASK_REF_MERGE_PSITE_OBJECT(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_MERGE_CONTACTS - Performs party ids  merge in JTF_TASK_CONTACTS table.
--		Updates CONTACT_ID column  in JTF_TASK_CONTACTS table with the merged
--		to contact id (party_id) value e.g. if party_id 1000 got merged
--		to party_id  2000 then, we have to update all records
--		with contact_id = 1000 to 2000.
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_CONTACTS(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	TASK_MERGE_CONTACT_POINTS - Performs contact_point_id merge in
--		JTF_TASK_PHONES table.
--		If contact_point_id 1000 got merged to contact_point_id 2000  then
-- 		we have to update all records with phone_id = 1000 to 2000
------------------------------------------------------------------------------------------

PROCEDURE TASK_MERGE_CONTACT_POINTS(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	SEARCH_MERGE_NUMBER_PARTY_ID - Performs party ids  merge in
--		JTF_PERZ_QUERY_PARAM table for Customer Number saved searches.
-- Columns: 	PARAMETER_VALUE where PARAMETER_NAME='CUSTOMER_ID'
------------------------------------------------------------------------------------------


PROCEDURE SEARCH_MERGE_NUMBER_PARTY_ID(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

------------------------------------------------------------------------------------------
-- Procedure: 	SEARCH_MERGE_NAME_PARTY_ID - Performs party ids  merge in
--		JTF_PERZ_QUERY_PARAM table for Customer Name saved searches.
-- Columns: 	PARAMETER_VALUE where PARAMETER_NAME='CUSTOMER_ID'
------------------------------------------------------------------------------------------

PROCEDURE SEARCH_MERGE_NAME_PARTY_ID(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);



------------------------------------------------------------------------------------------
-- Procedure: 	TASK_ASSIGNMENTS_MERGE - Performs party ids  merge in
--		JTF_TASK_ASSIGNMENTS table.
-- Columns: 	Updates RESOURCE_ID where RESOURCE_TYPE is of party type
------------------------------------------------------------------------------------------

PROCEDURE TASK_ASSIGNMENTS_MERGE(
    		p_entity_name                IN   VARCHAR2,
    		p_from_id                    IN   NUMBER,
    		x_to_id                      OUT NOCOPY  NUMBER,
    		p_from_fk_id                 IN   NUMBER,
    		p_to_fk_id                   IN   NUMBER,
    		p_parent_entity_name         IN   VARCHAR2,
    		p_batch_id                   IN   NUMBER,
    		p_batch_party_id             IN   NUMBER,
    		x_return_status              OUT NOCOPY  VARCHAR2);

END JTF_TASK_PARTY_MERGE_PKG;


 

/
