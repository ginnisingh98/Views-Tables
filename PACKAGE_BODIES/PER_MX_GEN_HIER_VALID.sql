--------------------------------------------------------
--  DDL for Package Body PER_MX_GEN_HIER_VALID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_GEN_HIER_VALID" as
/* $Header: permxgenhiervald.pkb 120.0 2005/06/01 01:26:14 appldev noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used to validate generic hierarchy
                'Mexican HRMS Statutory Reporting' for Mexico.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   05-MAY-2004  vpandya     115.0            Created.
   01-APR-2005  vpandya     115.2  4128530   Changed create_default_location
                                             Checking mode and create default
                                             location only when mode is not
                                             COPY.
*/
--

  /************************************************************************
   Name      : validate_nodes
   Purpose   : This procedure validates whether record exists for the same
               Legal Employer and GRE within business group for active
               hierarchy. This also validates whether record exists for
               the location within the same hiearchy for the same GRE
               or not.

               It will raise an error if entered values exists in
               the generic hierarchy for this business group,

   Arguments : IN
               P_BUSINESS_GROUP_ID           NUMBER
               P_ENTITY_ID                   VARCHAR2
               P_HIERARCHY_VERSION_ID        NUMBER
               P_NODE_TYPE                   VARCHAR2
               P_SEQ                         NUMBER
               P_PARENT_HIERARCHY_NODE_ID    NUMBER
               P_REQUEST_ID                  NUMBER
               P_PROGRAM_APPLICATION_ID      NUMBER
               P_PROGRAM_ID                  NUMBER
               P_PROGRAM_UPDATE_DATE         DATE
               P_EFFECTIVE_DATE              DATE
   Notes     :
  ************************************************************************/

  PROCEDURE validate_nodes( P_BUSINESS_GROUP_ID        in NUMBER
                           ,P_ENTITY_ID                in VARCHAR2
                           ,P_HIERARCHY_VERSION_ID     in NUMBER
                           ,P_NODE_TYPE                in VARCHAR2
                           ,P_SEQ                      in NUMBER
                           ,P_PARENT_HIERARCHY_NODE_ID in NUMBER
                           ,P_REQUEST_ID               in NUMBER
                           ,P_PROGRAM_APPLICATION_ID   in NUMBER
                           ,P_PROGRAM_ID               in NUMBER
                           ,P_PROGRAM_UPDATE_DATE      in DATE
                           ,P_EFFECTIVE_DATE           in DATE )
  IS

  CURSOR c_active_hier( cp_bus_grp_id  number
                       ,cp_hier_ver_id number
                       ,cp_eff_date    date ) IS
    select 1
    from   per_gen_hierarchy_versions
    where  business_group_id    = cp_bus_grp_id
    and    hierarchy_version_id = cp_hier_ver_id
    and    cp_eff_date between date_from and nvl(date_to,cp_eff_date)
    and    status = 'A';

  CURSOR c_node_exists( cp_bus_grp_id  number
                       ,cp_node_type   varchar2
                       ,cp_entity_id   varchar2
                       ,cp_eff_date    date ) IS
    select 1
    from   per_gen_hierarchy_nodes pghn
          ,per_gen_hierarchy_versions pghv
	  ,per_gen_hierarchy pgh
    where pghn.business_group_id = cp_bus_grp_id
    and   pghn.node_type = cp_node_type
    and   pghn.entity_id = cp_entity_id
    and   pghv.business_group_id = cp_bus_grp_id
    and   pghv.hierarchy_version_id = pghn.hierarchy_version_id
    and   cp_eff_date between pghv.date_from and nvl(pghv.date_to,cp_eff_date)
    and   pghv.status = 'A'
    and   pgh.business_group_id = cp_bus_grp_id
    and   pgh.hierarchy_id = pghv.hierarchy_id
    and   pgh.type = 'MEXICO HRMS';

  CURSOR c_loc_node_exists( cp_bus_grp_id       number
                           ,cp_hier_ver_id      number
                           ,cp_node_type        varchar2
                           ,cp_par_hier_node_id number
                           ,cp_entity_id        varchar2 ) IS
    select 1
    from   per_gen_hierarchy_nodes
    where  business_group_id    = cp_bus_grp_id
    and    hierarchy_version_id = cp_hier_ver_id
    and    node_type            = cp_node_type
    and    nvl(parent_hierarchy_node_id, -999) = nvl(cp_par_hier_node_id, -999)
    and    entity_id            = cp_entity_id;

    l_active_hierarchy number := 0;
    l_node_val_exists  number := 0;

  BEGIN

    hr_utility.trace('Entering: PER_MX_GEN_HIER_VALID.VALIDATE_NODES');
    hr_utility.trace('P_BUSINESS_GROUP_ID '||P_BUSINESS_GROUP_ID);
    hr_utility.trace('P_ENTITY_ID '||P_ENTITY_ID);
    hr_utility.trace('P_HIERARCHY_VERSION_ID '||P_HIERARCHY_VERSION_ID);
    hr_utility.trace('P_NODE_TYPE '||P_NODE_TYPE);
    hr_utility.trace('P_PARENT_HIERARCHY_NODE_ID '||P_PARENT_HIERARCHY_NODE_ID);
    hr_utility.trace('P_EFFECTIVE_DATE '||P_EFFECTIVE_DATE);


    open  c_active_hier( P_BUSINESS_GROUP_ID
                        ,P_HIERARCHY_VERSION_ID
                        ,P_EFFECTIVE_DATE );
    fetch c_active_hier into l_active_hierarchy;
    close c_active_hier;

    if l_active_hierarchy > 0 then

       hr_utility.trace('Active Hierarchy.');

       IF P_NODE_TYPE in ( 'MX LEGAL EMPLOYER', 'MX GRE' ) THEN

          hr_utility.trace('Node is either Legal Employer or GRE');

          open  c_node_exists( P_BUSINESS_GROUP_ID
                              ,P_NODE_TYPE
                              ,P_ENTITY_ID
                              ,P_EFFECTIVE_DATE );
          fetch c_node_exists into l_node_val_exists;
          close c_node_exists;


          IF l_node_val_exists > 0 THEN
             hr_utility.trace('Organization already exists in the hierarchy.');
             --
             fnd_message.set_name('PER', 'HR_MX_GENHIER_ND_EXISTS');
             fnd_message.raise_error;
             --
          END IF;

       ELSIF P_NODE_TYPE = 'MX LOCATION' THEN

          hr_utility.trace('Node is Location');

          open  c_loc_node_exists( P_BUSINESS_GROUP_ID
                                  ,P_HIERARCHY_VERSION_ID
                                  ,P_NODE_TYPE
                                  ,P_PARENT_HIERARCHY_NODE_ID
                                  ,P_ENTITY_ID );
          fetch c_loc_node_exists into l_node_val_exists;
          close c_loc_node_exists;


          IF l_node_val_exists > 0 THEN
             hr_utility.trace('Location record already exists.');
             --
             fnd_message.set_name('PER', 'HR_MX_GENHIER_LOC_EXIST_IN_GRE');
             fnd_message.raise_error;
             --
          END IF;

       END IF;

    end if;

    hr_utility.trace('Leaving: PER_MX_GEN_HIER_VALID.VALIDATE_NODES');

  END validate_nodes;

  /************************************************************************
   Name      : create_default_location
   Purpose   : This procedure creates default location when GRE is entered.
               It creates a records for the location for which
               is associated to the entered GRE.

   Arguments : IN
               P_HIERARCHY_NODE_ID           NUMBER
               P_BUSINESS_GROUP_ID           NUMBER
               P_ENTITY_ID                   VARCHAR2
               P_HIERARCHY_VERSION_ID        NUMBER
               P_NODE_TYPE                   VARCHAR2
               P_SEQ                         NUMBER
               P_PARENT_HIERARCHY_NODE_ID    NUMBER
               P_REQUEST_ID                  NUMBER
               P_PROGRAM_APPLICATION_ID      NUMBER
               P_PROGRAM_ID                  NUMBER
               P_PROGRAM_UPDATE_DATE         DATE
               P_EFFECTIVE_DATE              DATE
   Notes     :
  ************************************************************************/

  PROCEDURE create_default_location( P_HIERARCHY_NODE_ID        in NUMBER
                                    ,P_BUSINESS_GROUP_ID        in NUMBER
                                    ,P_ENTITY_ID                in VARCHAR2
                                    ,P_HIERARCHY_VERSION_ID     in NUMBER
                                    ,P_NODE_TYPE                in VARCHAR2
                                    ,P_SEQ                      in NUMBER
                                    ,P_PARENT_HIERARCHY_NODE_ID in NUMBER
                                    ,P_REQUEST_ID               in NUMBER
                                    ,P_PROGRAM_APPLICATION_ID   in NUMBER
                                    ,P_PROGRAM_ID               in NUMBER
                                    ,P_PROGRAM_UPDATE_DATE      in DATE
                                    ,P_EFFECTIVE_DATE           in DATE )
  IS

  CURSOR c_get_loc_id( cp_bus_grp_id number
                      ,cp_org_id     number) IS
    select location_id
    from   hr_organization_units
    where  business_group_id = cp_bus_grp_id
    and    organization_id   = cp_org_id;

    ln_location_id     number;
    ln_hier_node_id    number;
    ln_ovn             number;

  BEGIN

    hr_utility.trace('Entering: PER_MX_GEN_HIER_VALID.CREATE_DEFAULT_LOCATION');
    hr_utility.trace('P_HIERARCHY_NODE_ID '||P_HIERARCHY_NODE_ID);
    hr_utility.trace('P_BUSINESS_GROUP_ID '||P_BUSINESS_GROUP_ID);
    hr_utility.trace('P_ENTITY_ID '||P_ENTITY_ID);
    hr_utility.trace('P_HIERARCHY_VERSION_ID '||P_HIERARCHY_VERSION_ID);
    hr_utility.trace('P_NODE_TYPE '||P_NODE_TYPE);
    hr_utility.trace('P_PARENT_HIERARCHY_NODE_ID '||P_PARENT_HIERARCHY_NODE_ID);
    hr_utility.trace('P_EFFECTIVE_DATE '||P_EFFECTIVE_DATE);

    IF P_NODE_TYPE = 'MX GRE' AND
       NVL(PER_HIERARCHY_NODES_API.G_MODE, 'CREATE') <> 'COPY' THEN

       open  c_get_loc_id( P_BUSINESS_GROUP_ID
                          ,P_ENTITY_ID );
       fetch c_get_loc_id into ln_location_id;
       close c_get_loc_id;

       hr_utility.trace('Creating location '||ln_location_id||
                        ' for GRE '|| P_ENTITY_ID);

       per_hierarchy_nodes_api.create_hierarchy_nodes(
              p_hierarchy_node_id         => ln_hier_node_id
             ,p_business_group_id         => p_business_group_id
             ,p_entity_id                 => ln_location_id
             ,p_hierarchy_version_id      => p_hierarchy_version_id
             ,p_node_type                 => 'MX LOCATION'
             ,p_seq                       => 1
             ,p_parent_hierarchy_node_id  => p_hierarchy_node_id
             ,p_request_id                => p_request_id
             ,p_program_application_id    => p_program_application_id
             ,p_program_id                => p_program_id
             ,p_program_update_date       => p_program_update_date
             ,p_object_version_number     => ln_ovn
             ,p_effective_date            => p_effective_date );

    END IF;

    hr_utility.trace('Leaving: PER_MX_GEN_HIER_VALID.CREATE_DEFAULT_LOCATION');

  END create_default_location;

  /************************************************************************
   Name      : delete_nodes
   Purpose   : This procedure checks following stuff before deleting any
               record from the hierarchy.

               - DO NOT DELETE RECORD WHEN CHILD EXISTS
               - DO NOT DELETE LOCATION  WHEN IT IS ASSOICATED TO AN
                 ASSIGNMENT FOR ANY TIME PERIOD.

   Arguments : IN
               P_HIERARCHY_NODE_ID           NUMBER
               P_OBJECT_VERSION_NUMBER       NUMBER
   Notes     :
  ************************************************************************/

--  PROCEDURE delete_nodes( P_HIERARCHY_NODE_ID     in NUMBER
--                         ,P_OBJECT_VERSION_NUMBER in NUMBER)
--  IS
--
--  CURSOR c_child_node_exists( cp_hier_node_id number
--                             ,cp_ovn          number) IS
--    select 1
--    from   per_gen_hierarchy_nodes
--    where  parent_hierarchy_node_id = cp_hier_node_id
--    and    object_version_number    = cp_ovn;
--
--  CURSOR c_get_node_value( cp_hier_node_id number
--                          ,cp_ovn          number) IS
--    select entity_id, node_type
--    from   per_gen_hierarchy_nodes
--    where  hierarchy_node_id     = cp_hier_node_id
--    and    object_version_number = cp_ovn;
--
--  CURSOR c_asg_loc_exists( cp_loc_id number ) IS
--    select 1
--    from   per_all_assignments_f
--    where  location_id = cp_loc_id;
--
--    ln_child_node_exists number := 0;
--    ln_asg_loc_exists    number := 0;
--
--    lv_entity_id  varchar2(240);
--    lv_node_type  varchar2(240);
--
--
--  BEGIN
--
--    hr_utility.trace('Entering: PER_MX_GEN_HIER_VALID.DELETE_NODES');
--    hr_utility.trace('P_HIERARCHY_NODE_ID '||P_HIERARCHY_NODE_ID);
--    hr_utility.trace('P_OBJECT_VERSION_NUMBER '||P_OBJECT_VERSION_NUMBER);
--
--    open  c_child_node_exists( P_HIERARCHY_NODE_ID
--                              ,P_OBJECT_VERSION_NUMBER);
--    fetch c_child_node_exists into ln_child_node_exists;
--    close c_child_node_exists;
--
--    IF ln_child_node_exists > 0 THEN
--       hr_utility.trace('Child node exists.');
--       --
--       fnd_message.set_name('PER', 'HR_MX_INVALID_ELEMENT_NAME');
--       fnd_message.raise_error;
--       --
--    END IF;
--
--    open  c_get_node_value( P_HIERARCHY_NODE_ID
--                           ,P_OBJECT_VERSION_NUMBER);
--    fetch c_get_node_value into lv_entity_id
--                               ,lv_node_type;
--    close c_get_node_value;
--
--    IF lv_node_type = 'MX LOCATION' then
--
--       open  c_asg_loc_exists( lv_entity_id );
--       fetch c_asg_loc_exists into ln_asg_loc_exists;
--       close c_asg_loc_exists;
--
--       IF ln_asg_loc_exists > 0 THEN
--          hr_utility.trace('Location is/was associated to an assignment.');
--          --
--          fnd_message.set_name('PER', 'HR_MX_INVALID_ELEMENT_NAME');
--          fnd_message.raise_error;
--          --
--       END IF;
--
--    END IF;
--
--    hr_utility.trace('Leaving: PER_MX_GEN_HIER_VALID.DELETE_NODES');
--
--  END delete_nodes;

  /************************************************************************
   Name      : update_nodes
   Purpose   : This procedure restrict to update any node value when
               hierarchy is 'Active'.

   Arguments : IN
               P_HIERARCHY_NODE_ID           NUMBER
               P_ENTITY_ID                   VARCHAR2
               P_NODE_TYPE                   VARCHAR2
               P_SEQ                         NUMBER
               P_PARENT_HIERARCHY_NODE_ID    NUMBER
               P_REQUEST_ID                  NUMBER
               P_PROGRAM_APPLICATION_ID      NUMBER
               P_PROGRAM_ID                  NUMBER
               P_PROGRAM_UPDATE_DATE         DATE
               P_OBJECT_VERSION_NUMBER       NUMBER
               P_EFFECTIVE_DATE              DATE

   Notes     :
  ************************************************************************/

  PROCEDURE update_nodes( P_HIERARCHY_NODE_ID        in NUMBER
                         ,P_ENTITY_ID                in VARCHAR2
                         ,P_NODE_TYPE                in VARCHAR2
                         ,P_SEQ                      in NUMBER
                         ,P_PARENT_HIERARCHY_NODE_ID in NUMBER
                         ,P_REQUEST_ID               in NUMBER
                         ,P_PROGRAM_APPLICATION_ID   in NUMBER
                         ,P_PROGRAM_ID               in NUMBER
                         ,P_PROGRAM_UPDATE_DATE      in DATE
                         ,P_OBJECT_VERSION_NUMBER    in NUMBER
                         ,P_EFFECTIVE_DATE           in DATE )
  IS

  CURSOR c_get_node_val( cp_hier_node_id       number ) IS
    select business_group_id, hierarchy_version_id
    from   per_gen_hierarchy_nodes
    where  hierarchy_node_id = cp_hier_node_id;

  CURSOR c_active_hier( cp_bus_grp_id  number
                       ,cp_hier_ver_id number
                       ,cp_eff_date    date ) IS
    select 1
    from   per_gen_hierarchy_versions
    where  business_group_id    = cp_bus_grp_id
    and    hierarchy_version_id = cp_hier_ver_id
    and    cp_eff_date between date_from and nvl(date_to,cp_eff_date)
    and    status = 'A';

    l_active_hierarchy number := 0;
    ln_bus_grp_id      number;
    ln_hier_vers_id    number;

  BEGIN

    hr_utility.trace('Entering: PER_MX_GEN_HIER_VALID.UPDATE_NODES');
    hr_utility.trace('P_ENTITY_ID '||P_ENTITY_ID);
    hr_utility.trace('P_NODE_TYPE '||P_NODE_TYPE);
    hr_utility.trace('P_PARENT_HIERARCHY_NODE_ID '||P_PARENT_HIERARCHY_NODE_ID);
    hr_utility.trace('P_EFFECTIVE_DATE '||P_EFFECTIVE_DATE);

    open  c_get_node_val(P_HIERARCHY_NODE_ID);
    fetch c_get_node_val into ln_bus_grp_id, ln_hier_vers_id;
    close c_get_node_val;

    open  c_active_hier( ln_bus_grp_id
                        ,ln_hier_vers_id
                        ,p_effective_date );
    fetch c_active_hier into l_active_hierarchy;
    close c_active_hier;

    if l_active_hierarchy > 0 then
       hr_utility.trace('Update any node is not allowed.');
       --
       fnd_message.set_name('PER', 'HR_MX_GENHIER_ND_UPD_NOT_ALLOW');
       fnd_message.raise_error;
       --
    end if;

    hr_utility.trace('Leaving: PER_MX_GEN_HIER_VALID.UPDATE_NODES');

  END update_nodes;

  /************************************************************************
   Name      : update_hier_versions
   Purpose   : This procedure checks MX LEGAL EMPLOYER and MX GRE nodes
               whether that exists in any other active hierachy
               when hierachy is changed from 'Inactive' status to
               'Active' status.

   Arguments : IN
               P_HIERARCHY_VERSION_ID      NUMBER
               P_VERSION_NUMBER            NUMBER
               P_DATE_FROM                 DATE
               P_DATE_TO                   DATE
               P_STATUS                    VARCHAR2
               P_VALIDATE_FLAG             VARCHAR2
               P_REQUEST_ID                NUMBER
               P_PROGRAM_APPLICATION_ID    NUMBER
               P_PROGRAM_ID                NUMBER
               P_PROGRAM_UPDATE_DATE       DATE
               P_OBJECT_VERSION_NUMBER     NUMBER
               P_EFFECTIVE_DATE            DATE

   Notes     :
  ************************************************************************/

  PROCEDURE update_hier_versions( P_HIERARCHY_VERSION_ID   in NUMBER
                                 ,P_VERSION_NUMBER         in NUMBER
                                 ,P_DATE_FROM              in DATE
                                 ,P_DATE_TO                in DATE
                                 ,P_STATUS                 in VARCHAR2
                                 ,P_VALIDATE_FLAG          in VARCHAR2
                                 ,P_REQUEST_ID             in NUMBER
                                 ,P_PROGRAM_APPLICATION_ID in NUMBER
                                 ,P_PROGRAM_ID             in NUMBER
                                 ,P_PROGRAM_UPDATE_DATE    in DATE
                                 ,P_OBJECT_VERSION_NUMBER  in NUMBER
                                 ,P_EFFECTIVE_DATE         in DATE )
  IS

  CURSOR c_hier_status( cp_hier_ver_id number
                       ,cp_version_no  number ) IS
    select business_group_id, status
    from   per_gen_hierarchy_versions
    where  hierarchy_version_id = cp_hier_ver_id
    and    version_number       = cp_version_no;

  CURSOR c_get_nodes( cp_bus_grp_id  number
                     ,cp_hier_ver_id number) IS
    select node_type, entity_id
    from   per_gen_hierarchy_nodes
    where  business_group_id    = cp_bus_grp_id
    and    hierarchy_version_id = cp_hier_ver_id
    and    node_type            in ( 'MX LEGAL EMPLOYER', 'MX GRE' );

  CURSOR c_node_exists( cp_bus_grp_id  number
                       ,cp_node_type   varchar2
                       ,cp_entity_id   varchar2
                       ,cp_eff_date    date ) IS
    select 1
    from   per_gen_hierarchy_nodes pghn
          ,per_gen_hierarchy_versions pghv
          ,per_gen_hierarchy pgh
    where pghn.business_group_id = cp_bus_grp_id
    and   pghn.node_type = cp_node_type
    and   pghn.entity_id = cp_entity_id
    and   pghv.business_group_id = cp_bus_grp_id
    and   pghv.hierarchy_version_id = pghn.hierarchy_version_id
    and   cp_eff_date between pghv.date_from and nvl(pghv.date_to,cp_eff_date)
    and   pghv.status = 'A'
    and   pgh.business_group_id = cp_bus_grp_id
    and   pgh.hierarchy_id = pghv.hierarchy_id
    and   pgh.type = 'MEXICO HRMS';

    lv_hier_status  varchar2(240);
    ln_bus_grp_id   number;

    ln_node_exists  number := 0;

  BEGIN

    hr_utility.trace('Entering: PER_MX_GEN_HIER_VALID.UPDATE_HIER_VERSIONS');
    hr_utility.trace('P_HIERARCHY_VERSION_ID '||P_HIERARCHY_VERSION_ID);
    hr_utility.trace('P_VERSION_NUMBER '||P_VERSION_NUMBER);
    hr_utility.trace('P_DATE_FROM '||P_DATE_FROM);
    hr_utility.trace('P_DATE_TO '||P_DATE_TO);
    hr_utility.trace('P_STATUS '||P_STATUS);
    hr_utility.trace('P_EFFECTIVE_DATE '||P_EFFECTIVE_DATE);


    open  c_hier_status( P_HIERARCHY_VERSION_ID
                        ,P_VERSION_NUMBER );
    fetch c_hier_status into ln_bus_grp_id
                            ,lv_hier_status;
    close c_hier_status;

    hr_utility.trace('ln_bus_grp_id '||ln_bus_grp_id);
    hr_utility.trace('lv_hier_status '||lv_hier_status);

    if lv_hier_status = 'I' and p_status = 'A' then

       for nd in c_get_nodes(ln_bus_grp_id, p_hierarchy_version_id)
       loop

          open  c_node_exists( ln_bus_grp_id
                              ,nd.node_type
                              ,nd.entity_id
                              ,p_date_from );
          fetch c_node_exists into ln_node_exists;
          close c_node_exists;

          hr_utility.trace('ln_node_exists '||ln_node_exists);

          IF ln_node_exists > 0 THEN
             hr_utility.trace('Organization already exists in the hierarchy.');
             --
             fnd_message.set_name('PER', 'HR_MX_GENHIER_ND_EXST_IN_ACTIV');
             fnd_message.raise_error;
             --
          END IF;

       end loop;
    end if;

    hr_utility.trace('Leaving: PER_MX_GEN_HIER_VALID.UPDATE_HIER_VERSIONS');

  END update_hier_versions;

END per_mx_gen_hier_valid;

/
