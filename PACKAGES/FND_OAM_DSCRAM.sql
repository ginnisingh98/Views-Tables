--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM" AUTHID CURRENT_USER AS
/* $Header: AFOAMDSS.pls 120.6.12000000.3 2007/04/21 02:56:17 ssuprasa ship $ */

   ---------------
   -- Constants --
   ---------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This procedure is used to insert a policy into fnd_oam_ds_policies_b and
   -- fnd_oam_ds_policies_tl

procedure insert_policy
(
        policyid               OUT NOCOPY NUMBER,
        pname                  in varchar2,
        l_description          IN VARCHAR2 DEFAULT NULL,
        l_created_by           IN NUMBER,
        l_last_updated_by      IN NUMBER,
        l_last_update_login    IN NUMBER
);

   -- This procedure is used to update a policy

procedure update_policy
(
        policyid            in number,
        pname               in varchar2,
        l_description       IN VARCHAR2 DEFAULT NULL,
        l_last_updated_by   IN NUMBER,
        l_last_update_login IN NUMBER
);

   -- This procedure is used to insert an attribute as an element of a policy with policyid

procedure add_policy_attri_element
(
        policyid                in number,
        attribute_code          IN VARCHAR2,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

 --  add a new delete element for a policy with policyid

procedure add_policy_del_element
(
        policyid                in number,
        deleteid                IN NUMBER,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

 -- remove all policy elements for a policy with policyid

procedure remove_policy_elements
(
        policyid                in number
);

 -- insert a new policy set

procedure insert_policyset
(
        psetid                  OUT NOCOPY NUMBER,
        psetname                in varchar2,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

 -- update a new policy set

procedure update_policyset
(
        psetid                  in number,
        psetname                in varchar2,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

--  add a new policy as an element of a policy set with psetid

procedure add_pset_element
(
        psetid                  in number,
        policyid                in number,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

--  remove all elements for a policy set with psetid

procedure remove_pset_elements
(
        psetid                  in number
);

-- syschange
-- delete the pii attribute
procedure delete_pii_attribute
(
        attribute_code                  IN VARCHAR2
);


-- delete the policy
procedure delete_policy
(
        p_policy_id                  IN NUMBER
);

-- delete the policy
procedure delete_pset
(
        pset_id                  IN NUMBER
);

-- delete table for purge
procedure delete_tbl_to_purge
(
        deleteid                  IN NUMBER
);
-- add a new delete entry into FND_OAM_DS_DELETES

procedure add_delete
(
        l_table_name              IN VARCHAR2,
        l_owner                   IN VARCHAR2 DEFAULT NULL,
        l_where_clause            IN VARCHAR2 DEFAULT NULL,
        l_use_truncate_flag       IN VARCHAR2 DEFAULT NULL,
        l_created_by              IN NUMBER,
        l_last_updated_by         IN NUMBER,
        l_last_update_login       IN NUMBER
);


procedure update_delete
(
        l_delete_id               IN VARCHAR2,
        l_where_clause            IN VARCHAR2 DEFAULT NULL,
        l_use_truncate_flag       IN VARCHAR2 DEFAULT NULL,
        l_last_updated_by              IN NUMBER
) ;

 -- remove a delete entry with deleteid from FND_OAM_DS_DELETES

procedure remove_delete
(
        deleteid        in number
);

 -- insert a new PII privacy attribute

procedure insert_pii_attribute
(
        attribute_code          OUT NOCOPY VARCHAR2,
        attribute_name          IN VARCHAR2,
        l_algorithm             IN VARCHAR2 DEFAULT NULL,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);


procedure update_pii_attribute
(
        attribute_code          IN VARCHAR2,
        attribute_name          IN VARCHAR2,
        l_algorithm             IN VARCHAR2 DEFAULT NULL,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

-- update a PII privacy attribute
procedure pre_update_pii_attribute
(
        attribute_code          IN VARCHAR2

);

 -- add a new PII privacy attribute column for a privacy attribute with attribute_code

procedure add_attribute_col
(
        attribute_code          IN VARCHAR2,
        l_table_name            IN VARCHAR2,
        l_column_name           IN VARCHAR2,
        l_where_clause          IN VARCHAR2 DEFAULT NULL,
        l_algorithm             IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
);

/*
-Unused-
   -- remove a PII privacy attribute column for a privacy attribute with attribute_code

procedure remove_attribute_col
(
        attribute_code    IN VARCHAR2,
        l_table_name      IN VARCHAR2,
        l_column_name     IN VARCHAR2
);
*/

   -- DSCFG_PROCS-compliant procedure for the IMPORT phase.  Traverses a Policy Set
   -- and uses DSCFG_API_PKG calls to create entities for each PII attribute and
   -- OAM delete entity found.  This procedure tracks already inserted attributes to
   -- keep from inserting dups but does not track previous columns to detect conflicts
   -- since this is not required of import procedures.
   -- Invariants:
   --  Should only be invoked as part of the Intermediate Configuration Import phase,
   --  API's require state that is only set at that time.
   -- Parameters:
   --   None
   PROCEDURE IMPORT_POLICY_SET_TO_DSCFG;

end fnd_oam_dscram;

 

/
