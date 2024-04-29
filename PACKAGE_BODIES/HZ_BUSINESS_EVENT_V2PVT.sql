--------------------------------------------------------
--  DDL for Package Body HZ_BUSINESS_EVENT_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BUSINESS_EVENT_V2PVT" AS
/*$Header: ARH2BESB.pls 120.21 2006/03/24 07:23:44 svemuri ship $ */

--G_EXECUTE_API_CALLOUT CONSTANT VARCHAR2(100) := FND_PROFILE.VALUE('HZ_EXECUTE_API_CALLOUTS');
G_EXECUTE_API_CALLOUT CONSTANT VARCHAR2(1) := 'Y';

--------------------------------------
-- public procedures and functions
--------------------------------------

-- HZ_PARTY_V2PUB

PROCEDURE create_person_event (
    p_person_rec                            IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Person.create';

BEGIN
   SAVEPOINT  create_person_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );


        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_person_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);

        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_person_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;


        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_person_event;

END create_person_event;

PROCEDURE update_person_event (
    p_person_rec                            IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_old_person_rec                        IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Person.update';

BEGIN
   SAVEPOINT update_person_event;
   --  Raise Event ONLY if profile is set to 'Y'.
   --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
   --  delete from HZ_PARAMS exists.
   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_person_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_person_rec, 'OLD' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_person_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_person_event;

END update_person_event;

PROCEDURE create_group_event (
    p_group_rec                             IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Group.create';

BEGIN
  SAVEPOINT create_group_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_group_rec, 'NEW' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();


        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_group_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_group_event;

END create_group_event;

PROCEDURE update_group_event (
    p_group_rec                             IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE,
    p_old_group_rec                         IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Group.update';

BEGIN
  SAVEPOINT update_group_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_group_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_group_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();


        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_group_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO  update_group_event;

END update_group_event;

PROCEDURE create_organization_event (
    p_organization_rec                      IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Organization.create';

BEGIN
  SAVEPOINT  create_organization_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.
   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_organization_rec, 'NEW' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_organization_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_organization_event;

END create_organization_event;

PROCEDURE update_organization_event (
    p_organization_rec                      IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_old_organization_rec                  IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Organization.update';

BEGIN
  SAVEPOINT update_organization_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_organization_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_organization_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_organization_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_organization_event;

END update_organization_event;

-- HZ_RELATIONSHIP_V2PUB

PROCEDURE create_relationship_event (
    p_relationship_rec                      IN     HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_party_created                         IN     VARCHAR2
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Relationship.create';

BEGIN
  SAVEPOINT create_relationship_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_relationship_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, 'P_PARTY_CREATED', p_party_created, 'NEW' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'RELATIONSHIP_ID' );
        l_param.SetValue( p_relationship_rec.relationship_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'P_PARTY_CREATED' );
        l_param.SetValue( p_party_created );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_relationship_event;

END create_relationship_event;

PROCEDURE update_relationship_event (
    p_relationship_rec                      IN     HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_old_relationship_rec                  IN     HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Relationship.update';

BEGIN
   SAVEPOINT update_relationship_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_relationship_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_relationship_rec, 'OLD' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'RELATIONSHIP_ID' );
        l_param.SetValue( p_relationship_rec.relationship_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_relationship_event;

END update_relationship_event;

-- HZ_PARTY_SITE_V2PUB

PROCEDURE create_party_site_event (
    p_party_site_rec                        IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.PartySite.create';

BEGIN
  SAVEPOINT create_party_site_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_party_site_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_SITE_ID' );
        l_param.SetValue( p_party_site_rec.party_site_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_party_site_event;
END create_party_site_event;

PROCEDURE update_party_site_event (
    p_party_site_rec                        IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
    p_old_party_site_rec                    IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.PartySite.update';

BEGIN
  SAVEPOINT update_party_site_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_party_site_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_party_site_rec, 'OLD' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_SITE_ID' );
        l_param.SetValue( p_party_site_rec.party_site_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_party_site_event;

END update_party_site_event;

PROCEDURE create_party_site_use_event (
    p_party_site_use_rec                    IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.PartySiteUse.create';

BEGIN
  SAVEPOINT create_party_site_use_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_party_site_use_rec, 'NEW' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_SITE_USE_ID' );
        l_param.SetValue( p_party_site_use_rec.party_site_use_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO  create_party_site_use_event;

END create_party_site_use_event;

PROCEDURE update_party_site_use_event (
    p_party_site_use_rec                    IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
    p_old_party_site_use_rec                IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.PartySiteUse.update';

BEGIN
  SAVEPOINT update_party_site_use_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_party_site_use_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_party_site_use_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'PARTY_SITE_USE_ID' );
        l_param.SetValue( p_party_site_use_rec.party_site_use_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_party_site_use_event;

END update_party_site_use_event;

-- HZ_PARTY_CONTACT_V2PUB

PROCEDURE create_org_contact_event (
    p_org_contact_rec                       IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE

) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.OrgContact.create';

BEGIN
  SAVEPOINT  create_org_contact_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_org_contact_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'ORG_CONTACT_ID' );
        l_param.SetValue( p_org_contact_rec.org_contact_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_org_contact_event;

END create_org_contact_event;

PROCEDURE update_org_contact_event (
    p_org_contact_rec                       IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE,
    p_old_org_contact_rec                   IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.OrgContact.update';

BEGIN
   SAVEPOINT update_org_contact_event;
     --  Raise Event ONLY if profile is set to 'Y'.
     --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
     --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_org_contact_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_org_contact_rec, 'OLD' );
        END IF;
*/

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'ORG_CONTACT_ID' );
        l_param.SetValue( p_org_contact_rec.org_contact_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_org_contact_event;

END update_org_contact_event;

PROCEDURE create_org_contact_role_event (
    p_org_contact_role_rec                  IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.OrgContactRole.create';

BEGIN
  SAVEPOINT  create_org_contact_role_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_org_contact_role_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'ORG_CONTACT_ROLE_ID' );
        l_param.SetValue( p_org_contact_role_rec.org_contact_role_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_org_contact_role_event;

END create_org_contact_role_event;

PROCEDURE update_org_contact_role_event (
    p_org_contact_role_rec                  IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE,
    p_old_org_contact_role_rec              IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.OrgContactRole.update';

BEGIN
  SAVEPOINT update_org_contact_role_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_org_contact_role_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_org_contact_role_rec, 'OLD');
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'ORG_CONTACT_ROLE_ID' );
        l_param.SetValue( p_org_contact_role_rec.org_contact_role_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_org_contact_role_event;

END update_org_contact_role_event;

--HZ_LOCATION_V2PUB

PROCEDURE create_location_event (
    p_location_rec                          IN     HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Location.create';

BEGIN
  SAVEPOINT  create_location_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_location_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'LOCATION_ID' );
        l_param.SetValue( p_location_rec.location_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_location_event;

END create_location_event;

PROCEDURE update_location_event (
    p_location_rec                          IN     HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
    p_old_location_rec                      IN     HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.Location.update';

BEGIN
  SAVEPOINT update_location_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           HZ_PARAM_PKG.SetParameter( l_key, p_location_rec, 'NEW' );
           HZ_PARAM_PKG.SetParameter( l_key, p_old_location_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );


        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'LOCATION_ID' );
        l_param.SetValue( p_location_rec.location_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO update_location_event;

END update_location_event;

  -- HZ_CONTACT_POINT_V2PUB


  -- MODIFICATION HISTORY:
  --   19-NOV-2001    Joe del Callar    Bug 2116225: Added support for bank
  --                                    consolidation - param p_eft_rec.
  PROCEDURE create_contact_point_event (
    p_contact_point_rec IN   hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec         IN     hz_contact_point_v2pub.edi_rec_type,
    p_eft_rec         IN     hz_contact_point_v2pub.eft_rec_type,
    p_email_rec       IN     hz_contact_point_v2pub.email_rec_type,
    p_phone_rec       IN     hz_contact_point_v2pub.phone_rec_type,
    p_telex_rec       IN     hz_contact_point_v2pub.telex_rec_type,
    p_web_rec         IN     hz_contact_point_v2pub.web_rec_type
  ) IS

    l_list            WF_PARAMETER_LIST_T;
    l_param           WF_PARAMETER_T;
    l_key             VARCHAR2(240);
    l_exist           VARCHAR2(1);
    l_event_name      VARCHAR2(240) := 'oracle.apps.ar.hz.ContactPoint.create';

  BEGIN
    SAVEPOINT create_contact_point_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := hz_event_pkg.exist_subscription( l_event_name );

      --Get the item key
      l_key := hz_event_pkg.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
      IF l_exist = 'Y' THEN
         --Set Parameter
         hz_param_pkg.setparameter( l_key, p_contact_point_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_edi_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_email_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_phone_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_telex_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_web_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_eft_rec, 'NEW' );
      END IF;
*/
      -- initialization of object variables
      l_list := WF_PARAMETER_LIST_T();

      -- Add Context values to the list
      hz_event_pkg.addparamenvtolist(l_list);
      l_param := WF_PARAMETER_T( NULL, NULL );


      -- fill the parameters list
      l_list.extend;
      l_param.setname( 'CONTACT_POINT_ID' );
      l_param.setvalue( p_contact_point_rec.contact_point_id );
      l_list(l_list.last) := l_param;

        -- Raise Event
      hz_event_pkg.raise_event(
        p_event_name        => l_event_name,
        p_event_key         => l_key,
        p_parameters        => l_list );

      l_list.delete;

   END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);
      fnd_msg_pub.add;
      ROLLBACK TO create_contact_point_event;
  END create_contact_point_event;


  -- MODIFICATION HISTORY:
  --   19-NOV-2001    Joe del Callar    Bug 2116225: Added support for bank
  --                                    consolidation - params p_eft_rec and
  --                                    p_old_eft_rec.
  PROCEDURE update_contact_point_event (
    p_contact_point_rec     IN   hz_contact_point_v2pub.contact_point_rec_type,
    p_old_contact_point_rec IN   hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec               IN   hz_contact_point_v2pub.edi_rec_type,
    p_old_edi_rec           IN   hz_contact_point_v2pub.edi_rec_type,
    p_eft_rec               IN   hz_contact_point_v2pub.eft_rec_type,
    p_old_eft_rec           IN   hz_contact_point_v2pub.eft_rec_type,
    p_email_rec             IN   hz_contact_point_v2pub.email_rec_type,
    p_old_email_rec         IN   hz_contact_point_v2pub.email_rec_type,
    p_phone_rec             IN   hz_contact_point_v2pub.phone_rec_type,
    p_old_phone_rec         IN   hz_contact_point_v2pub.phone_rec_type,
    p_telex_rec             IN   hz_contact_point_v2pub.telex_rec_type,
    p_old_telex_rec         IN   hz_contact_point_v2pub.telex_rec_type,
    p_web_rec               IN   hz_contact_point_v2pub.web_rec_type,
    p_old_web_rec           IN   hz_contact_point_v2pub.web_rec_type
  ) IS

    l_list            WF_PARAMETER_LIST_T;
    l_param           WF_PARAMETER_T;
    l_key             VARCHAR2(240);
    l_exist           VARCHAR2(1);
    l_event_name      VARCHAR2(240) := 'oracle.apps.ar.hz.ContactPoint.update';

  BEGIN
    SAVEPOINT update_contact_point_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := hz_event_pkg.exist_subscription( l_event_name );

      --Get the item key
      l_key := hz_event_pkg.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
      IF l_exist = 'Y' THEN

         --Set Parameter
         hz_param_pkg.setparameter( l_key, p_contact_point_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_edi_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_email_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_phone_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_telex_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_web_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_eft_rec, 'NEW' );
         hz_param_pkg.setparameter( l_key, p_old_contact_point_rec, 'OLD' );
         hz_param_pkg.setparameter( l_key, p_old_edi_rec, 'OLD' );
         hz_param_pkg.setparameter( l_key, p_old_email_rec, 'OLD' );
         hz_param_pkg.setparameter( l_key, p_old_phone_rec, 'OLD' );
         hz_param_pkg.setparameter( l_key, p_old_telex_rec, 'OLD' );
         hz_param_pkg.setparameter( l_key, p_old_web_rec, 'OLD' );
         hz_param_pkg.setparameter( l_key, p_old_eft_rec, 'OLD' );
      END IF;
*/
      -- initialization of object variables
      l_list := WF_PARAMETER_LIST_T();

      -- Add Context values to the list
      hz_event_pkg.addparamenvtolist(l_list);
      l_param := WF_PARAMETER_T( NULL, NULL );


      -- fill the parameters list
      l_list.extend;
      l_param.setname( 'CONTACT_POINT_ID' );
      l_param.setvalue( p_contact_point_rec.contact_point_id );
      l_list(l_list.last) := l_param;

      -- Raise Event
      hz_event_pkg.raise_event(
        p_event_name        => l_event_name,
        p_event_key         => l_key,
        p_parameters        => l_list );

      l_list.delete;

   END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);
      fnd_msg_pub.add;
      ROLLBACK TO update_contact_point_event;
  END update_contact_point_event;

-- HZ_CONTACT_PREFERENCE_V2PUB

PROCEDURE create_contact_prefer_event (
    p_contact_preference_rec                IN     HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ContactPreference.create';

BEGIN
  SAVEPOINT  create_contact_prefer_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_contact_preference_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CONTACT_PREFERENCE_ID' );
        l_param.SetValue( p_contact_preference_rec.contact_preference_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_contact_prefer_event;

END create_contact_prefer_event;

PROCEDURE update_contact_prefer_event (
    p_contact_preference_rec                IN     HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE,
    p_old_contact_preference_rec            IN     HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ContactPreference.update';

BEGIN
  SAVEPOINT update_contact_prefer_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_contact_preference_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_contact_preference_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CONTACT_PREFERENCE_ID' );
        l_param.SetValue( p_contact_preference_rec.contact_preference_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_contact_prefer_event;

END update_contact_prefer_event;

-- HZ_CUST_ACCOUNT_V2PUB

PROCEDURE create_cust_account_event (
    p_cust_account_rec                      IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE,
    p_person_rec                            IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAccount.create';

BEGIN
  SAVEPOINT create_cust_account_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_account_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_person_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_customer_profile_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, 'P_CREATE_PROFILE_AMT', p_create_profile_amt, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_account_rec.cust_account_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_person_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );
        l_param.SetValue( p_customer_profile_rec.cust_account_profile_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'P_CREATE_PROFILE_AMT' );
        l_param.SetValue( p_create_profile_amt );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_cust_account_event;

END create_cust_account_event;

PROCEDURE create_cust_account_event (
    p_cust_account_rec                      IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE,
    p_organization_rec                      IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAccount.create';

BEGIN
  SAVEPOINT create_cust_account_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_account_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_organization_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_customer_profile_rec, 'NEW' );
          hz_param_pkg.setparameter( l_key, 'P_CREATE_PROFILE_AMT', p_create_profile_amt, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_account_rec.cust_account_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'PARTY_ID' );
        l_param.SetValue( p_organization_rec.party_rec.party_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );
        l_param.SetValue( p_customer_profile_rec.cust_account_profile_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'P_CREATE_PROFILE_AMT' );
        l_param.SetValue( p_create_profile_amt );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_cust_account_event;

END create_cust_account_event;

PROCEDURE update_cust_account_event (
    p_cust_account_rec                      IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE,
    p_old_cust_account_rec                  IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAccount.update';

BEGIN
   SAVEPOINT update_cust_account_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_account_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_cust_account_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_account_rec.cust_account_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_cust_account_event;

END update_cust_account_event;

PROCEDURE create_cust_acct_relate_event (
    p_cust_acct_relate_rec                  IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAcctRelate.create';

BEGIN
  SAVEPOINT create_cust_acct_relate_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_acct_relate_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        /* 3456489. Added org_id as a parameter. */
        hz_event_pkg.AddParamEnvToList(x_list   => l_list,
       				       p_org_id => p_cust_acct_relate_rec.org_id);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_acct_relate_rec.cust_account_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'RELATED_CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_acct_relate_rec.related_cust_account_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  create_cust_acct_relate_event;

END create_cust_acct_relate_event;

PROCEDURE update_cust_acct_relate_event (
    p_cust_acct_relate_rec                  IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE,
    p_old_cust_acct_relate_rec              IN     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAcctRelate.update';

BEGIN
   SAVEPOINT update_cust_acct_relate_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_acct_relate_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_cust_acct_relate_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
       /* 3456489. Added org_id as a parameter. */
        hz_event_pkg.AddParamEnvToList(x_list => l_list,
				p_org_id => p_cust_acct_relate_rec.org_id);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_acct_relate_rec.cust_account_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'RELATED_CUST_ACCOUNT_ID' );
        l_param.SetValue( p_cust_acct_relate_rec.related_cust_account_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  update_cust_acct_relate_event;

END update_cust_acct_relate_event;

-- HZ_CUSTOMER_PROFILE_V2PUB

PROCEDURE create_customer_profile_event (
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustomerProfile.create';

BEGIN
   SAVEPOINT create_customer_profile_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_customer_profile_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, 'P_CREATE_PROFILE_AMT', p_create_profile_amt, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );
        l_param.SetValue( p_customer_profile_rec.cust_account_profile_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'P_CREATE_PROFILE_AMT' );
        l_param.SetValue( p_create_profile_amt );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  create_customer_profile_event;

END create_customer_profile_event;

PROCEDURE update_customer_profile_event (
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_old_customer_profile_rec              IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustomerProfile.update';

BEGIN
  SAVEPOINT update_customer_profile_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_customer_profile_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_customer_profile_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );
        l_param.SetValue( p_customer_profile_rec.cust_account_profile_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_customer_profile_event;

END update_customer_profile_event;

PROCEDURE create_cust_profile_amt_event (
    p_cust_profile_amt_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustProfileAmt.create';

BEGIN
   SAVEPOINT create_cust_profile_amt_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_profile_amt_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCT_PROFILE_AMT_ID' );
        l_param.SetValue( p_cust_profile_amt_rec.cust_acct_profile_amt_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_cust_profile_amt_event;


END create_cust_profile_amt_event;

PROCEDURE update_cust_profile_amt_event (
    p_cust_profile_amt_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE,
    p_old_cust_profile_amt_rec              IN     HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustProfileAmt.update';

BEGIN
  SAVEPOINT update_cust_profile_amt_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_profile_amt_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_cust_profile_amt_rec, 'OLD');
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCT_PROFILE_AMT_ID' );
        l_param.SetValue( p_cust_profile_amt_rec.cust_acct_profile_amt_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_cust_profile_amt_event;

END update_cust_profile_amt_event;

-- HZ_CUST_ACCOUNT_SITE_V2PUB

PROCEDURE create_cust_acct_site_event (
    p_cust_acct_site_rec                    IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAcctSite.create';

BEGIN
  SAVEPOINT  create_cust_acct_site_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_acct_site_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        /* 3456489. Added org_id as a parameter. */
        hz_event_pkg.AddParamEnvToList(x_list => l_list,
				p_org_id => p_cust_acct_site_rec.org_id);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCT_SITE_ID' );
        l_param.SetValue( p_cust_acct_site_rec.cust_acct_site_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_cust_acct_site_event;

END create_cust_acct_site_event;

PROCEDURE update_cust_acct_site_event (
    p_cust_acct_site_rec                    IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE,
    p_old_cust_acct_site_rec                IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAcctSite.update';

BEGIN
   SAVEPOINT update_cust_acct_site_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.

   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_acct_site_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_cust_acct_site_rec, 'OLD');
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        /* 3456489. Added org_id as a parameter. */
        hz_event_pkg.AddParamEnvToList(x_list => l_list,
				p_org_id => p_cust_acct_site_rec.org_id);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCT_SITE_ID' );
        l_param.SetValue( p_cust_acct_site_rec.cust_acct_site_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_cust_acct_site_event;

END update_cust_acct_site_event;

PROCEDURE create_cust_site_use_event (
    p_cust_site_use_rec                     IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec                  IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile                        IN     VARCHAR2,
    p_create_profile_amt                    IN     VARCHAR2
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAcctSiteUse.create';

BEGIN
   SAVEPOINT create_cust_site_use_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_site_use_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_customer_profile_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, 'P_CREATE_PROFILE', p_create_profile, 'NEW' );
           hz_param_pkg.setparameter( l_key, 'P_CREATE_PROFILE_AMT', p_create_profile_amt, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        /* 3456489. Added org_id as a parameter. */
        hz_event_pkg.AddParamEnvToList(x_list => l_list,
				p_org_id => p_cust_site_use_rec.org_id);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'SITE_USE_ID' );
        l_param.SetValue( p_cust_site_use_rec.site_use_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );
        l_param.SetValue( p_customer_profile_rec.cust_account_profile_id );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'P_CREATE_PROFILE' );
        l_param.SetValue( p_create_profile );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'P_CREATE_PROFILE_AMT' );
        l_param.SetValue( p_create_profile_amt );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_cust_site_use_event;

END create_cust_site_use_event;

PROCEDURE update_cust_site_use_event (
    p_cust_site_use_rec                     IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE,
    p_old_cust_site_use_rec                 IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAcctSiteUse.update';

BEGIN
   SAVEPOINT update_cust_site_use_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_site_use_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_cust_site_use_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
       /* 3456489. Added org_id as a parameter. */
        hz_event_pkg.AddParamEnvToList(x_list => l_list,
				p_org_id => p_cust_site_use_rec.org_id);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'SITE_USE_ID' );
        l_param.SetValue( p_cust_site_use_rec.site_use_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_cust_site_use_event;

END update_cust_site_use_event;

-- HZ_CUST_ACCOUNT_ROLE_V2PUB

PROCEDURE create_cust_account_role_event (
    p_cust_account_role_rec                 IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAccountRole.create';

BEGIN
   SAVEPOINT create_cust_account_role_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_account_role_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ROLE_ID' );
        l_param.SetValue( p_cust_account_role_rec.cust_account_role_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_cust_account_role_event;

END create_cust_account_role_event;

PROCEDURE update_cust_account_role_event (
    p_cust_account_role_rec                 IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE,
    p_old_cust_account_role_rec             IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CustAccountRole.update';

BEGIN
   SAVEPOINT update_cust_account_role_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

    	   --Set Parameter
           hz_param_pkg.setparameter( l_key, p_cust_account_role_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_cust_account_role_rec, 'OLD');
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CUST_ACCOUNT_ROLE_ID' );
        l_param.SetValue( p_cust_account_role_rec.cust_account_role_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_cust_account_role_event;

END update_cust_account_role_event;

PROCEDURE create_role_resp_event (
    p_role_responsibility_rec               IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.RoleResponsibility.create';

BEGIN
    SAVEPOINT create_role_resp_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_role_responsibility_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'RESPONSIBILITY_ID' );
        l_param.SetValue( p_role_responsibility_rec.responsibility_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  create_role_resp_event;

END create_role_resp_event;

PROCEDURE update_role_resp_event (
    p_role_responsibility_rec               IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE,
    p_old_role_responsibility_rec           IN     HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.RoleResponsibility.update';

BEGIN
    SAVEPOINT update_role_resp_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_role_responsibility_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_role_responsibility_rec, 'OLD');
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'RESPONSIBILITY_ID' );
        l_param.SetValue( p_role_responsibility_rec.responsibility_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_role_resp_event;

END update_role_resp_event;

-- HZ_CLASSIFICATION_V2PUB

PROCEDURE create_class_category_event (
    p_class_category_rec                    IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCategory.create';

BEGIN
   SAVEPOINT  create_class_category_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_class_category_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_category_rec.class_category );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  create_class_category_event;

END create_class_category_event;

PROCEDURE update_class_category_event (
    p_class_category_rec                    IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_REC_TYPE,
    p_old_class_category_rec                IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCategory.update';

BEGIN
    SAVEPOINT update_class_category_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_class_category_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_class_category_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_category_rec.class_category );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_class_category_event;

END update_class_category_event;

-- Added as part of bug 5053099
PROCEDURE create_class_code_event (
    p_class_code_rec   IN    HZ_CLASSIFICATION_V2PUB.CLASS_CODE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCode.create';

BEGIN
   SAVEPOINT  create_class_code_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_code_rec.type );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CLASS_CODE' );
        l_param.SetValue( p_class_code_rec.code );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  create_class_codey_event;

END create_class_code_event;

-- Added as part of bug 5053099
PROCEDURE update_class_code_event (
    p_class_code_rec                    IN HZ_CLASSIFICATION_V2PUB.CLASS_CODE_REC_TYPE,
    p_old_class_code_rec                IN HZ_CLASSIFICATION_V2PUB.CLASS_CODE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCode.update';

BEGIN
    SAVEPOINT update_class_code_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN


        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_code_rec.type );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CLASS_CODE' );
        l_param.SetValue( p_class_code_rec.code );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_class_category_event;

END update_class_code_event;


PROCEDURE create_class_code_rel_event (
    p_class_code_relation_rec               IN     HZ_CLASSIFICATION_V2PUB.CLASS_CODE_RELATION_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCodeRelation.create';

BEGIN
   SAVEPOINT  create_class_code_rel_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_class_code_relation_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_code_relation_rec.class_category );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CLASS_CODE' );
        l_param.SetValue( p_class_code_relation_rec.class_code );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'SUB_CLASS_CODE' );
        l_param.SetValue( p_class_code_relation_rec.sub_class_code );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_class_code_rel_event;

END create_class_code_rel_event;

PROCEDURE update_class_code_rel_event (
    p_class_code_relation_rec               IN     HZ_CLASSIFICATION_V2PUB.CLASS_CODE_RELATION_REC_TYPE,
    p_old_class_code_relation_rec           IN     HZ_CLASSIFICATION_V2PUB.CLASS_CODE_RELATION_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCodeRelation.update';

BEGIN
   SAVEPOINT update_class_code_rel_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_class_code_relation_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_class_code_relation_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_code_relation_rec.class_category );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'CLASS_CODE' );
        l_param.SetValue( p_class_code_relation_rec.class_code );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'SUB_CLASS_CODE' );
        l_param.SetValue( p_class_code_relation_rec.sub_class_code );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_class_code_rel_event;

END update_class_code_rel_event;

PROCEDURE create_code_assignment_event (
    p_code_assignment_rec                   IN     HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CodeAssignment.create';

BEGIN
   SAVEPOINT create_code_assignment_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );


        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_code_assignment_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CODE_ASSIGNMENT_ID' );
        l_param.SetValue( p_code_assignment_rec.code_assignment_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO  create_code_assignment_event;

END create_code_assignment_event;

PROCEDURE update_code_assignment_event (
    p_code_assignment_rec                   IN     HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE,
    p_old_code_assignment_rec               IN     HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.CodeAssignment.update';

BEGIN
   SAVEPOINT update_code_assignment_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.



   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_code_assignment_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_code_assignment_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CODE_ASSIGNMENT_ID' );
        l_param.SetValue( p_code_assignment_rec.code_assignment_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_code_assignment_event;

END update_code_assignment_event;

PROCEDURE create_class_cat_use_event (
    p_class_category_use_rec                IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_USE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCategoryUse.create';

BEGIN
    SAVEPOINT create_class_cat_use_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
    --l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );


        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_class_category_use_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_category_use_rec.class_category );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'OWNER_TABLE' );
        l_param.SetValue( p_class_category_use_rec.owner_table );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'COLUMN_NAME' );
        l_param.SetValue( p_class_category_use_rec.column_name );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_class_cat_use_event;

END create_class_cat_use_event;

PROCEDURE update_class_cat_use_event (
    p_class_category_use_rec                IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_USE_REC_TYPE,
    p_old_class_category_use_rec            IN     HZ_CLASSIFICATION_V2PUB.CLASS_CATEGORY_USE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.ClassCategoryUse.update';

BEGIN
    SAVEPOINT update_class_cat_use_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN

           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_class_category_use_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_class_category_use_rec, 'OLD' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'CLASS_CATEGORY' );
        l_param.SetValue( p_class_category_use_rec.class_category );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'OWNER_TABLE' );
        l_param.SetValue( p_class_category_use_rec.owner_table );
        l_list(l_list.last) := l_param;

        l_list.extend;
        l_param.SetName( 'COLUMN_NAME' );
        l_param.SetValue( p_class_category_use_rec.column_name );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_class_cat_use_event;

END update_class_cat_use_event;

-- HZ_PERSON_INFO_V2PUB

PROCEDURE create_person_language_event (
    p_person_language_rec                   IN     HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.PersonLanguage.create';

BEGIN
   SAVEPOINT create_person_language_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_person_language_rec, 'NEW' );
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'LANGUAGE_USE_REFERENCE_ID' );
        l_param.SetValue( p_person_language_rec.language_use_reference_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_person_language_event;

END create_person_language_event;

PROCEDURE update_person_language_event (
    p_person_language_rec                   IN     HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE,
    p_old_person_language_rec               IN     HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE
) IS

    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.hz.PersonLanguage.update';

BEGIN
   SAVEPOINT update_person_language_event;
    --  Raise Event ONLY if profile is set to 'Y'.
    --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
    --  delete from HZ_PARAMS exists.


   IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line(s) as part of bug4369710 fix
--    l_exist := HZ_EVENT_PKG.exist_subscription( l_event_name );

        --Get the item key
        l_key := HZ_EVENT_PKG.item_key( l_event_name );

-- commenting the following line(s) as part of bug4369710 fix
/*
        IF l_exist = 'Y' THEN
           --Set Parameter
           hz_param_pkg.setparameter( l_key, p_person_language_rec, 'NEW' );
           hz_param_pkg.setparameter( l_key, p_old_person_language_rec, 'OLD');
        END IF;
*/
        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        hz_event_pkg.AddParamEnvToList(l_list);
        l_param := WF_PARAMETER_T( NULL, NULL );

        -- fill the parameters list
        l_list.extend;
        l_param.SetName( 'LANGUAGE_USE_REFERENCE_ID' );
        l_param.SetValue( p_person_language_rec.language_use_reference_id );
        l_list(l_list.last) := l_param;

        -- Raise Event
        HZ_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

   END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_person_language_event;

END update_person_language_event;



-- HZ_CUST_ACCT_INFO_PUB
/* Bug No : 4580024
PROCEDURE create_bill_pref_event
( p_billing_preferences_rec   IN HZ_CUST_ACCT_INFO_PUB.BILLING_PREFERENCES_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.BillingPreference.create';
BEGIN
 SAVEPOINT create_bill_pref_event;

 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix

   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_billing_preferences_rec, 'NEW');
   END IF;

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('BILLING_PREFERENCES_ID');
   l_param.SetValue(P_BILLING_PREFERENCES_REC.BILLING_PREFERENCES_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;


END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_bill_pref_event;
END create_bill_pref_event;


PROCEDURE update_bill_pref_event
( p_billing_preferences_rec   IN HZ_CUST_ACCT_INFO_PUB.BILLING_PREFERENCES_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.BillingPreference.update';
BEGIN
 SAVEPOINT update_bill_pref_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix

   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_billing_preferences_rec, 'NEW');
   END IF;

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('BILLING_PREFERENCES_ID');
   l_param.SetValue(P_BILLING_PREFERENCES_REC.BILLING_PREFERENCES_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_bill_pref_event;
END update_bill_pref_event;


PROCEDURE create_bank_acct_uses_event
( p_bank_acct_uses_rec   IN  HZ_CUST_ACCT_INFO_PUB.BANK_ACCT_USES_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.BankAccountUse.create';
BEGIN
 SAVEPOINT create_bank_acct_uses_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix

   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_bank_acct_uses_rec, 'NEW');
   END IF;

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('BANK_ACCOUNT_USES_ID');
   l_param.SetValue(P_BANK_ACCT_USES_REC.BANK_ACCOUNT_USES_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_bank_acct_uses_event;
END create_bank_acct_uses_event;


PROCEDURE update_bank_acct_uses_event
( p_bank_acct_uses_rec   IN  HZ_CUST_ACCT_INFO_PUB.BANK_ACCT_USES_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.BankAccountUse.update';
BEGIN
 SAVEPOINT update_bank_acct_uses_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix

   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_bank_acct_uses_rec, 'NEW');
   END IF;

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('BANK_ACCOUNT_USES_ID');
   l_param.SetValue(P_BANK_ACCT_USES_REC.BANK_ACCOUNT_USES_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_bank_acct_uses_event;
END update_bank_acct_uses_event;


PROCEDURE create_suspension_act_event
( p_suspension_activity_rec   IN  HZ_CUST_ACCT_INFO_PUB.SUSPENSION_ACTIVITY_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.SuspensionActivity.create';
BEGIN
 SAVEPOINT  create_suspension_act_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix

   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_suspension_activity_rec, 'NEW');
   END IF;

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('SUSPENSION_ACTIVITY_ID');
   l_param.SetValue(P_SUSPENSION_ACTIVITY_REC.SUSPENSION_ACTIVITY_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_suspension_act_event;
END create_suspension_act_event;


PROCEDURE update_suspension_act_event
( p_suspension_activity_rec   IN  HZ_CUST_ACCT_INFO_PUB.SUSPENSION_ACTIVITY_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.SuspensionActivity.update';
BEGIN
 SAVEPOINT update_suspension_act_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);

   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_suspension_activity_rec, 'NEW');
   END IF;

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('SUSPENSION_ACTIVITY_ID');
   l_param.SetValue(P_SUSPENSION_ACTIVITY_REC.SUSPENSION_ACTIVITY_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_suspension_act_event;
END update_suspension_act_event;

 Bug No : 4580024 */

-- HZ_ORG_INFO_PUB

PROCEDURE create_stock_markets_event
( p_stock_markets_rec IN HZ_ORG_INFO_PUB.STOCK_MARKETS_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.StockMarket.create';
BEGIN
 SAVEPOINT create_stock_markets_event;

 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_stock_markets_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('STOCK_EXCHANGE_ID');
   l_param.SetValue(P_STOCK_MARKETS_REC.STOCK_EXCHANGE_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_stock_markets_event;

END create_stock_markets_event;


PROCEDURE update_stock_markets_event
( p_stock_markets_rec IN HZ_ORG_INFO_PUB.STOCK_MARKETS_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.StockMarket.update';
BEGIN
 SAVEPOINT update_stock_markets_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_stock_markets_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('STOCK_EXCHANGE_ID');
   l_param.SetValue(P_STOCK_MARKETS_REC.STOCK_EXCHANGE_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_stock_markets_event;

END update_stock_markets_event;


PROCEDURE create_sec_issued_event
( p_security_issued_rec IN HZ_ORG_INFO_PUB.SECURITY_ISSUED_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.SecurityIssued.create';
BEGIN
 SAVEPOINT create_sec_issued_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_security_issued_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('SECURITY_ISSUED_ID');
   l_param.SetValue(P_SECURITY_ISSUED_REC.SECURITY_ISSUED_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_sec_issued_event;

END create_sec_issued_event;


PROCEDURE update_sec_issued_event
( p_security_issued_rec IN HZ_ORG_INFO_PUB.SECURITY_ISSUED_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.SecurityIssued.update';
BEGIN
 SAVEPOINT update_sec_issued_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_security_issued_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('SECURITY_ISSUED_ID');
   l_param.SetValue(P_SECURITY_ISSUED_REC.SECURITY_ISSUED_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_sec_issued_event;

END update_sec_issued_event;

PROCEDURE create_fin_reports_event
( p_financial_reports_rec IN HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.FinancialReport.create';
BEGIN
 SAVEPOINT create_fin_reports_event;

 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_financial_reports_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('FINANCIAL_REPORT_ID');
   l_param.SetValue(P_FINANCIAL_REPORTS_REC.FINANCIAL_REPORT_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_fin_reports_event;

END create_fin_reports_event;


PROCEDURE update_fin_reports_event
( p_financial_reports_rec IN HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE,
  p_old_financial_reports_rec IN HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.FinancialReport.update';
BEGIN
 SAVEPOINT update_fin_reports_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_financial_reports_rec, 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_financial_reports_rec, 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('FINANCIAL_REPORT_ID');
   l_param.SetValue(P_FINANCIAL_REPORTS_REC.FINANCIAL_REPORT_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_fin_reports_event;

END update_fin_reports_event;


PROCEDURE create_fin_numbers_event
( p_financial_numbers_rec IN HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.FinancialNumber.create';
BEGIN
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN

-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_financial_numbers_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('FINANCIAL_NUMBER_ID');
   l_param.SetValue(P_FINANCIAL_NUMBERS_REC.FINANCIAL_NUMBER_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_fin_numbers_event;

END create_fin_numbers_event;


PROCEDURE update_fin_numbers_event
( p_financial_numbers_rec IN HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE ,
  p_old_financial_numbers_rec IN HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.FinancialNumber.update';
BEGIN
 SAVEPOINT update_fin_numbers_events;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_financial_numbers_rec, 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_financial_numbers_rec, 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('FINANCIAL_NUMBER_ID');
   l_param.SetValue(P_FINANCIAL_NUMBERS_REC.FINANCIAL_NUMBER_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_fin_numbers_event;
END update_fin_numbers_event;


PROCEDURE create_certifications_event
( p_certifications_rec IN HZ_ORG_INFO_PUB.CERTIFICATIONS_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.Certification.create';
BEGIN
 SAVEPOINT create_certifications_event;

 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_certifications_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('CERTIFICATION_ID');
   l_param.SetValue(P_CERTIFICATIONS_REC.CERTIFICATION_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_certifications_event;
END create_certifications_event;


PROCEDURE update_certifications_event
( p_certifications_rec IN HZ_ORG_INFO_PUB.CERTIFICATIONS_REC_TYPE )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.Certification.update';
BEGIN
 SAVEPOINT update_certifications_event;

 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_certifications_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('CERTIFICATION_ID');
   l_param.SetValue(P_CERTIFICATIONS_REC.CERTIFICATION_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_certifications_event;
END update_certifications_event;

-- HZ_PERSON_INFO_V2PUB

PROCEDURE create_person_interest_event
(p_per_interest_rec   IN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.PersonInterest.create';
BEGIN
 SAVEPOINT create_per_interest_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_per_interest_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('PERSON_INTEREST_ID');
   l_param.SetValue(P_PER_INTEREST_REC.PERSON_INTEREST_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_per_interest_event;

END create_person_interest_event;


PROCEDURE update_person_interest_event
(p_per_interest_rec       IN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE,
 p_old_per_interest_rec   IN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE
)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.PersonInterest.update';
BEGIN
 SAVEPOINT update_per_interest_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_per_interest_rec, 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_per_interest_rec, 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('PERSON_INTEREST_ID');
   l_param.SetValue(P_PER_INTEREST_REC.PERSON_INTEREST_ID);
   l_list(l_list.last):= l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_per_interest_event;

END update_person_interest_event;


PROCEDURE create_citizenship_event
(p_citizenship_rec   IN HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.Citizenship.create';
BEGIN
 SAVEPOINT create_citizenship_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_citizenship_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('CITIZENSHIP_ID');
   l_param.SetValue(P_CITIZENSHIP_REC.CITIZENSHIP_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_citizenship_event;

END create_citizenship_event;



PROCEDURE update_citizenship_event
(p_citizenship_rec       IN HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE,
 p_old_citizenship_rec   IN HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE
 )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.Citizenship.update';
BEGIN
 SAVEPOINT update_citizenship_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_citizenship_rec, 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_citizenship_rec, 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('CITIZENSHIP_ID');
   l_param.SetValue(P_CITIZENSHIP_REC.CITIZENSHIP_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_citizenship_event;

END update_citizenship_event;

-- HZ_PERSON_INFO_V2PUB

PROCEDURE create_education_event
(p_education_rec   IN HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.Education.create';
BEGIN
 SAVEPOINT create_education_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_education_rec, 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('EDUCATION_ID');
   l_param.SetValue(P_EDUCATION_REC.EDUCATION_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_education_event;

END create_education_event;



PROCEDURE update_education_event
(p_education_rec   IN HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE,
 p_old_education_rec   IN HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE
 )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.Education.update';
BEGIN
 SAVEPOINT update_education_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_education_rec, 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_education_rec, 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('EDUCATION_ID');
   l_param.SetValue(P_EDUCATION_REC.EDUCATION_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_education_event;

END update_education_event;

-- HZ_PERSON_INFO_V2PUB

PROCEDURE update_emp_history_event
(p_emp_history_rec   IN HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE,
 p_old_emp_history_rec   IN HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE
)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.EmploymentHistory.update';
BEGIN
 SAVEPOINT update_emp_history_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_emp_history_rec , 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_emp_history_rec , 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('EMPLOYMENT_HISTORY_ID');
   l_param.SetValue(P_EMP_HISTORY_REC.EMPLOYMENT_HISTORY_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_emp_history_event;

END update_emp_history_event;


PROCEDURE create_emp_history_event
(p_emp_history_rec   IN HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.EmploymentHistory.create';
BEGIN
 SAVEPOINT create_emp_history_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_emp_history_rec , 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('EMPLOYMENT_HISTORY_ID');
   l_param.SetValue(P_EMP_HISTORY_REC.EMPLOYMENT_HISTORY_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_emp_history_event;

END create_emp_history_event;


PROCEDURE create_work_class_event
(p_work_class_rec   IN HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.WorkClass.create';
BEGIN
 SAVEPOINT create_work_class_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_work_class_rec , 'NEW');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('WORK_CLASS_ID');
   l_param.SetValue(P_WORK_CLASS_REC.WORK_CLASS_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_work_class_event;

END create_work_class_event;


PROCEDURE update_work_class_event
(p_work_class_rec       IN HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE,
 p_old_work_class_rec   IN HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.WorkClass.update';
BEGIN
 SAVEPOINT update_work_class_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_work_class_rec , 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_work_class_rec , 'OLD');
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('WORK_CLASS_ID');
   l_param.SetValue(P_WORK_CLASS_REC.WORK_CLASS_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_work_class_event;

END update_work_class_event;



-- HZ_PARTY_INFO_PUB

PROCEDURE create_credit_ratings_event
(p_credit_ratings_rec IN HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.CreditRating.create';
BEGIN
 SAVEPOINT create_credit_ratings_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('CREDIT_RATING_ID');
   l_param.SetValue(P_CREDIT_RATINGS_REC.CREDIT_RATING_ID);
   l_list(l_list.last) := l_param;

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_credit_ratings_rec, 'NEW');
   END IF;
*/
   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_credit_ratings_event;

END create_credit_ratings_event;


PROCEDURE update_credit_ratings_event
(p_credit_ratings_rec IN HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE,
 p_old_credit_ratings_rec IN HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.CreditRating.update';
BEGIN
 SAVEPOINT update_credit_ratings_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('CREDIT_RATING_ID');
   l_param.SetValue(P_CREDIT_RATINGS_REC.CREDIT_RATING_ID);
   l_list(l_list.last) := l_param;
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_credit_ratings_rec, 'NEW');
      hz_param_pkg.setparameter(l_key, p_old_credit_ratings_rec, 'OLD');
   END IF;
*/
   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_credit_ratings_event;

END update_credit_ratings_event;


PROCEDURE create_fin_profile_event
(p_financial_profile_rec IN HZ_PARTY_INFO_PUB.FINANCIAL_PROFILE_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.FinancialProfile.create';
BEGIN
 SAVEPOINT create_fin_profile_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('FINANCIAL_PROFILE_ID');
   l_param.SetValue(P_FINANCIAL_PROFILE_REC.FINANCIAL_PROFILE_ID);
   l_list(l_list.last) := l_param;
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_financial_profile_rec, 'NEW');
   END IF;
*/
   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_fin_profile_event;

END create_fin_profile_event;


PROCEDURE update_fin_profile_event
(p_financial_profile_rec IN HZ_PARTY_INFO_PUB.FINANCIAL_PROFILE_REC_TYPE)
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.FinancialProfile.update';
BEGIN
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('FINANCIAL_PROFILE_ID');
   l_param.SetValue(P_FINANCIAL_PROFILE_REC.FINANCIAL_PROFILE_ID);
   l_list(l_list.last) := l_param;
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_financial_profile_rec, 'NEW');
   END IF;
*/
   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_fin_profile_event;

END update_fin_profile_event;

PROCEDURE create_orig_system_ref_event (
    p_orig_sys_reference_rec	  IN HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE
  ) is
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.origSystemRef.create';
BEGIN
 SAVEPOINT create_orig_system_ref_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);

   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('ORIG_SYSTEM_REF_ID');
   l_param.SetValue(P_ORIG_SYS_REFERENCE_REC.ORIG_SYSTEM_REF_ID);
   l_list(l_list.last) := l_param;
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
      --Set Parameter
      hz_param_pkg.setparameter(l_key, p_orig_sys_reference_rec, 'NEW');
   END IF;
*/
   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO create_orig_system_ref_event;

END create_orig_system_ref_event;

PROCEDURE update_orig_system_ref_event (
    p_orig_sys_reference_rec	  IN HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    p_old_orig_sys_reference_re   IN HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE
  )
IS
 l_list wf_parameter_list_t;
 l_param  wf_parameter_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.ar.hz.origSystemRef.update';
BEGIN

  SAVEPOINT update_orig_system_ref_event;
 --  Raise Event ONLY if profile is set to 'Y'.
 --  Populate HZ_PARAMS only if Profile is set to 'Y' AMD a subscription to
 --  delete from HZ_PARAMS exists.


IF G_EXECUTE_API_CALLOUT = 'Y' THEN
-- commenting the following line as part of bug4369710 fix
-- l_yn := hz_event_pkg.exist_subscription(l_event_name);

   --Get the item key
   l_key := HZ_EVENT_PKG.item_key(l_event_name);
-- commenting the following line as part of bug4369710 fix
/*
   IF l_yn = 'Y' THEN
       --Set Parameter
       HZ_PARAM_PKG.SetParameter( l_key, p_orig_sys_reference_rec, 'NEW' );
       HZ_PARAM_PKG.SetParameter( l_key, p_orig_sys_reference_rec, 'OLD' );
   END IF;
*/
   -- initialization of object variables
   l_list := wf_parameter_list_t();

   -- Add Context values to the list
   hz_event_pkg.AddParamEnvToList(l_list);
   l_param := WF_PARAMETER_T( NULL, NULL );

   -- fill the parameters list
   l_list.extend;
   l_param.SetName('ORIG_SYSTEM_REF_ID');
   l_param.SetValue(P_ORIG_SYS_REFERENCE_REC.ORIG_SYSTEM_REF_ID);
   l_list(l_list.last) := l_param;

   -- Raise Event
   hz_event_pkg.raise_event(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_list);
   l_list.DELETE;

END IF;
EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR' ,SQLERRM);
  fnd_msg_pub.add;
  ROLLBACK TO update_orig_system_ref_event;

END update_orig_system_ref_event;

END hz_business_event_v2pvt;

/
