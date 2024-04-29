--------------------------------------------------------
--  DDL for Package Body FND_UPDATE_USER_PREF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_UPDATE_USER_PREF_PUB" AS
/* $Header: fndpiprb.pls 120.1 2005/07/02 03:35:01 appldev noship $ */

--  Global constants
G_PKG_NAME   VARCHAR2(100) := 'FND_UPDATE_USER_PREF_PUB';
--  Pre-defined validation levels
--

PROCEDURE set_donotuse_preference
(  p_api_version     IN  NUMBER,
   p_init_msg_list   IN  VARCHAR2 ,
   p_commit          IN  VARCHAR2 ,
   p_user_id  	     IN  NUMBER   ,
   p_party_id        IN  NUMBER   ,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2
)
IS

l_api_name     VARCHAR2(100);
l_api_name_1   VARCHAR2(100);
l_api_version  number;

l_sysdate      Date ;

Cursor c_bus_purp
    IS
select  purpose_code,
        purpose_default_code
  from  fnd_business_purposes_b
  where  purpose_code <> 'ALL';


CURSOR  c_cont_pref(l_party_id in number,
                    l_purpose_code in varchar2)
    IS
select  contact_preference_id,
        object_version_number,
        contact_type
        contact_level_table,
        contact_level_table_id	,
        preference_code	,
        preference_topic_type	,
        preference_topic_type_id  ,
        preference_topic_type_code  ,
        preference_start_date	 ,
        preference_end_date	,
        requested_by		,
        reason_code		,
        status	   ,
        created_by_module  ,
        contact_type
  FROM HZ_CONTACT_PREFERENCES pref
 WHERE pref.CONTACT_LEVEL_TABLE_ID    = l_party_id
   AND pref.CONTACT_LEVEL_TABLE       = 'HZ_PARTIES'
   AND pref.preference_topic_type_code = l_purpose_code  -- this will be l_purpose_code
   AND pref.preference_topic_type     = 'FND_BUSINESS_PURPOSES_B' -- this will be FND_BUSINESS_PURPOSES
   AND pref.contact_type              = 'PRIV_PREF'
--   AND sysdate between pref.preference_start_date and nvl(pref.preference_end_date, sysdate +1)
   AND status                         = 'A';

r_cont_pref    c_cont_pref%rowtype;

i              number ;
k              number ;

cursor c_party(l_user_id number)
    is
select person_party_id
  from fnd_user
 where user_id = l_user_id;

l_party_id number ;

l_contact_preference_record    hz_contact_preference_v2pub.contact_preference_rec_type;

l_object_version_number  number;
l_return_status          varchar2(20);
l_msg_count              number;
l_msg_data               varchar2(2000);
l_contact_preference_id  number;
l_requested_by           varchar2(30);

BEGIN

-- initialize variables
l_api_name      :=  'SET_DONOTUSE_PREFERENCE';
l_api_name_1    :=  'SET_DONOTUSE_PREFERENCE';
l_api_version   :=  1;
l_sysdate       :=  sysdate;
i               :=  0;
k               :=  0;
x_return_status :=  fnd_api.g_ret_sts_success;
l_party_id      :=  p_party_id;

/* requested_by is validated against lookup_code for lookup_type = 'REQUESTED_BY'. valid values are INTERNAL/PARTY */
l_requested_by := 'INTERNAL';

/* Standard call to check for call compatibility */
/*
IF NOT fnd_api.compatible_api_call (l_api_version,
                                    p_api_version,
                                    l_api_name,
                                     g_pkg_name) THEN
    RAISE fnd_api.g_exc_unexpected_error;
END IF;
*/

/* Initialize message list if p_init_msg_list is set to TRUE */

IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
END IF;

/*If party id has not been passed then get the party id from fnd_user */
if(p_party_id is null)
then
   open c_party(p_user_id);
   fetch c_party into l_party_id;
   close c_party;
end if;


IF (l_party_id is not null)
THEN

  -- check to see if the 'ALL' Business Purpose is already opted out
   open c_cont_pref(l_party_id,
                    'ALL');
   fetch c_cont_pref into r_cont_pref;
   close c_cont_pref;
   -- if opted out record already exists then no inserts required for ALL
   -- else insert the ALL opt-out record. This is to hold state of the Opt-out of All Purposes button in UI
   -- for the party
      IF(r_cont_pref.preference_code = 'DO_NOT')
      THEN
             null;
       ELSE
            -- create the record
            --l_contact_preference_record.contact_preference_id      := r_cont_pref.contact_preference_id;
            l_contact_preference_record.contact_level_table          := 'HZ_PARTIES';
            l_contact_preference_record.contact_level_table_id       := l_party_id;
            l_contact_preference_record.contact_type                 := 'PRIV_PREF';
            l_contact_preference_record.preference_code              := 'DO_NOT';
            l_contact_preference_record.preference_topic_type        := 'FND_BUSINESS_PURPOSES_B';
            --l_contact_preference_record.preference_topic_type_id     := 'ALL';
            l_contact_preference_record.preference_topic_type_code   := 'ALL';
            l_contact_preference_record.preference_start_date        := trunc(sysdate);
            l_contact_preference_record.preference_end_date          := null ;
            l_contact_preference_record.requested_by                 := l_requested_by;
            l_contact_preference_record.status                       := 'A' ;
            l_contact_preference_record.created_by_module            := 'FND Data Privacy' ;
            l_contact_preference_record.application_id               := 0 ;


            -- change the API Name temporarily so that in case of unexpected error
            -- it is properly caught
            l_api_name := l_api_name||'-CREATE_CONTACT_PREFERENCE';

            hz_contact_preference_v2pub.create_contact_preference (
                                      p_init_msg_list          => FND_API.G_FALSE,
                                      p_contact_preference_rec => l_contact_preference_record,
                                      x_contact_preference_id  => l_contact_preference_id,
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data
                                      );

            -- set back the API name to original name
            l_api_name := l_api_name_1;

            IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('FND', 'FND_PII_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','CREATE_CONTACT_PREFERENCE');
                 fnd_message.set_token('P_API_NAME', l_api_name);
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
            END IF; -- end of x_return_status check

         END IF; -- end of DO check

  FOR r_bus_purp in  c_bus_purp
  LOOP
     IF(r_bus_purp.purpose_default_code = 'N')
     THEN
     -- if the default option is No choice then there will not be any records in HZ_CONTACT_PREFERENCES
         null;
     ELSIF(r_bus_purp.purpose_default_code = 'O')
     THEN
     -- if the default option is Opt Out, and a party opt in record exists in HZ_CONTACT_PREFERENCES
     -- the record has to be deleted
         open c_cont_pref(l_party_id,
                          r_bus_purp.purpose_code);
         fetch c_cont_pref into r_cont_pref;
         close c_cont_pref;

         -- if a opt in record exists then that has to be deleted
         IF(r_cont_pref.preference_code = 'DO')
         THEN
              delete hz_contact_preferences
              where  contact_preference_id = r_cont_pref.contact_preference_id;
         END IF; -- end of DO check

     ELSIF(r_bus_purp.purpose_default_code = 'I')
     THEN
     -- if the default option is opt in, and a party opt out record DOES NOT exist in HZ_CONTACT_PREFERENCES
     -- then create an opt-out record for the Business Purpose and Party
         open c_cont_pref(l_party_id,
                          r_bus_purp.purpose_code);
         fetch c_cont_pref into r_cont_pref;
         --close c_cont_pref;

         -- if opt-out record does not exist then create it
         IF(r_cont_pref.preference_code = 'DO_NOT')
         THEN
             null;
         ELSE
            -- create the record
            --l_contact_preference_record.contact_preference_id      := r_cont_pref.contact_preference_id;
            l_contact_preference_record.contact_level_table          := 'HZ_PARTIES';
            l_contact_preference_record.contact_level_table_id       := l_party_id;
            l_contact_preference_record.contact_type                 := 'PRIV_PREF';
            l_contact_preference_record.preference_code              := 'DO_NOT';
            l_contact_preference_record.preference_topic_type        := 'FND_BUSINESS_PURPOSES_B';
            --l_contact_preference_record.preference_topic_type_id     := r_bus_purp.purpose_code;
            l_contact_preference_record.preference_topic_type_code   := r_bus_purp.purpose_code;
            l_contact_preference_record.preference_start_date        := trunc(sysdate);
            l_contact_preference_record.preference_end_date          := null ;
            l_contact_preference_record.requested_by                 := l_requested_by;
            l_contact_preference_record.status                       := 'A' ;
            l_contact_preference_record.created_by_module            := 'FND Data Privacy' ;
            l_contact_preference_record.application_id               := 0; --r_cont_pref.application_id ;


            -- change the API Name temporarily so that in case of unexpected error
            -- it is properly caught
            l_api_name := l_api_name||'-CREATE_CONTACT_PREFERENCE';

            hz_contact_preference_v2pub.create_contact_preference (
                                      p_init_msg_list          => FND_API.G_FALSE,
                                      p_contact_preference_rec => l_contact_preference_record,
                                      x_contact_preference_id  => l_contact_preference_id,
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data
                                      );

            -- set back the API name to original name
            l_api_name := l_api_name_1;

            IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('FND', 'FND_PII_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','CREATE_CONTACT_PREFERENCE');
                 fnd_message.set_token('P_API_NAME', l_api_name);
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
            END IF; -- end of x_return_status check

         END IF; -- end of DO check

         close c_cont_pref;
     END IF;
  END LOOP; -- end of c_bus_purp


END IF; -- end of p_user_id check

IF (p_commit = FND_API.G_TRUE)
THEN
   COMMIT;
END IF;

 -- add confirmation message
 fnd_message.set_name ('FND', 'FND_PII_CONFIRM_SAVE');
 FND_MSG_PUB.add;
 FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('FND', 'FND_PII_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

END set_donotuse_preference;

PROCEDURE set_default_preference
(  p_api_version     IN  NUMBER,
   p_init_msg_list   IN  VARCHAR2 ,
   p_commit          IN  VARCHAR2 ,
   p_user_id  	     IN  NUMBER   ,
   p_party_id        IN  NUMBER   ,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2
)
IS

l_api_name  VARCHAR2(100) ;
l_api_name_1  VARCHAR2(100) ;
l_api_version   number ;

l_sysdate Date ;

Cursor c_purp_attr
    IS
select  purpose_attribute_id,
        attribute_default_code
  from  fnd_purpose_attributes;

--r_purp_attr c_purp_attr%rowtype;


cursor c_party(l_user_id number)
    is
select customer_id
  from fnd_user
 where user_id = l_user_id;

l_party_id number;


l_return_status          varchar2(20);
l_msg_count              number;
l_msg_data               varchar2(2000);
l_contact_preference_id  number;
l_requested_by           varchar2(30);

BEGIN

-- initialize variables

-- initialize variables
l_api_name      :=  'SET_DEFAULT_PREFERENCE';
l_api_name_1    :=  'SET_DEFAULT_PREFERENCE';
l_api_version   :=  1;
l_sysdate       :=  sysdate;
x_return_status :=  fnd_api.g_ret_sts_success;

l_party_id       := p_party_id;
l_requested_by   := 'INTERNAL';
l_party_id       := p_party_id;


IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
END IF;

/*If party id has not been passed then get the party id from fnd_user */
if(p_party_id is null)
then
   open c_party(p_user_id);
   fetch c_party into l_party_id;
   close c_party;
end if;


IF (l_party_id is not null)
THEN
/* as the default options are to be set for the party, so all opt-in/opt-out records from contact
   preferences will have to be removed */
delete  HZ_CONTACT_PREFERENCES pref
 WHERE pref.CONTACT_LEVEL_TABLE_ID    = l_party_id
   AND pref.CONTACT_LEVEL_TABLE       = 'HZ_PARTIES'
   AND pref.preference_topic_type     = 'FND_BUSINESS_PURPOSES_B'
   AND pref.contact_type              = 'PRIV_PREF';

END IF; -- end of p_party_id check

 fnd_message.set_name ('FND', 'FND_PII_CONFIRM_SAVE');
 FND_MSG_PUB.add;
 FND_MSG_PUB.Count_And_Get
 (
   p_count => x_msg_count,
   p_data  => x_msg_data
 );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('FND', 'FND_PII_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

END set_default_preference;


PROCEDURE set_purpose_option
(  p_api_version     IN  NUMBER,
   p_init_msg_list   IN  VARCHAR2 ,
   p_commit          IN  VARCHAR2 ,
   p_user_id  	     IN  NUMBER   ,
   p_party_id        IN  NUMBER   ,
   p_option          IN  preference_tbl ,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2
)
IS
l_api_name  VARCHAR2(100) ;
l_api_name_1  VARCHAR2(100) ;
l_api_version   number ;

l_sysdate Date ;

Cursor c_purp_attr
    IS
select  purpose_attribute_id,
        attribute_default_code
  from  fnd_purpose_attributes;

--r_purp_attr c_purp_attr%rowtype;

CURSOR  c_cont_pref(l_party_id in number,
                    l_purpose_code in varchar2)
    IS
select  contact_preference_id,
        preference_code
  FROM HZ_CONTACT_PREFERENCES pref
 WHERE pref.CONTACT_LEVEL_TABLE_ID    = l_party_id
   AND pref.CONTACT_LEVEL_TABLE       = 'HZ_PARTIES'
   --AND pref.preference_topic_type_id  = l_purpose_code
   AND pref.preference_topic_type_code = l_purpose_code
   AND pref.preference_topic_type      = 'FND_BUSINESS_PURPOSES_B'
   AND pref.contact_type               = 'PRIV_PREF'
   AND status                          = 'A';

r_cont_pref    c_cont_pref%rowtype;

i              number ;
k              number ;

cursor c_party(l_user_id number)
    is
select customer_id
  from fnd_user
 where user_id = l_user_id;

l_party_id number ;

l_contact_preference_record    hz_contact_preference_v2pub.contact_preference_rec_type;

l_object_version_number  number;
l_return_status          varchar2(20);
l_msg_count              number;
l_msg_data               varchar2(2000);
l_contact_preference_id  number;
l_requested_by           varchar2(30) ;
l_all_flag               varchar2(1);

BEGIN

-- initialize variables
l_api_name      :=  'SET_PURPOSE_OPTION';
l_api_name_1    :=  'SET_PURPOSE_OPTION';
l_api_version   :=  1;
l_sysdate       :=  sysdate;
i               :=  0;
k               :=  0;
x_return_status :=  fnd_api.g_ret_sts_success;

l_party_id       := p_party_id;
l_requested_by   := 'INTERNAL';
l_all_flag       := 'N';


IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
END IF;

IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
END IF;

/*If party id has not been passed then get the party id from fnd_user */
if(p_party_id is null)
then
   open c_party(p_user_id);
   fetch c_party into l_party_id;
   close c_party;
end if;


IF((l_party_id is not null) and ( p_option.count > 0))
THEN
  FOR i in p_option.first..p_option.last
  LOOP
     l_contact_preference_record := null;
     IF(p_option(i).purpose_default_code = 'N')
     THEN
        -- do nothing
        null;
     ELSIF(p_option(i).purpose_default_code in ('I', 'O'))
     THEN
        IF(p_option(i).user_option = p_option(i).purpose_default_code )
        THEN
          -- if user option is same as default code then delete any opt-in/opt-out from hz_contact_preferences table
          -- check to see if any record already exists .
           r_cont_pref := null;
           open c_cont_pref(l_party_id, p_option(i).purpose_code);
           fetch c_cont_pref into r_cont_pref;
           if(c_cont_pref%FOUND)
           THEN
              l_all_flag := 'Y';

              delete HZ_CONTACT_PREFERENCES pref
               WHERE pref.CONTACT_LEVEL_TABLE_ID      = l_party_id
                 AND pref.CONTACT_LEVEL_TABLE         = 'HZ_PARTIES'
                 AND pref.preference_topic_type       = 'FND_BUSINESS_PURPOSES_B'
                 AND pref.contact_type                = 'PRIV_PREF'
                 AND pref.preference_topic_type_code  = p_option(i).purpose_code;

           END IF;
           close c_cont_pref;


        ELSIF(p_option(i).user_option = 'I')
        THEN
           -- check to see if a opt-in record already exists . if not insert the record
           r_cont_pref := null;
           open c_cont_pref(l_party_id, p_option(i).purpose_code);
           fetch c_cont_pref into r_cont_pref;
           close c_cont_pref;

           IF(r_cont_pref.preference_code = 'DO')
           THEN
              -- do nothing as OPT-IN record already exists
              null;
           ELSIF(r_cont_pref.preference_code = 'DO_NOT')
           THEN
             l_all_flag := 'Y';
             -- delete the OPT-OUT record , in the unlikely case that it exisrs
             delete HZ_CONTACT_PREFERENCES pref
             where pref.contact_preference_id = r_cont_pref.contact_preference_id;
           ELSE
		      l_all_flag := 'Y';
            -- insert the OPT-IN record
            --l_contact_preference_record.contact_preference_id      := r_cont_pref.contact_preference_id;
              l_contact_preference_record.contact_level_table          := 'HZ_PARTIES';
              l_contact_preference_record.contact_level_table_id       := l_party_id;
              l_contact_preference_record.contact_type                 := 'PRIV_PREF';
              l_contact_preference_record.preference_code              := 'DO';
              l_contact_preference_record.preference_topic_type        := 'FND_BUSINESS_PURPOSES_B';
              --l_contact_preference_record.preference_topic_type_id     := p_option(i).purpose_code;
               l_contact_preference_record.preference_topic_type_code := p_option(i).purpose_code;
              l_contact_preference_record.preference_start_date        := trunc(sysdate);
              l_contact_preference_record.preference_end_date          := null ;
              l_contact_preference_record.requested_by                 := l_requested_by;
              l_contact_preference_record.status                       := 'A' ;
              l_contact_preference_record.created_by_module            := 'FND Data Privacy' ;
              l_contact_preference_record.application_id               := 0; --r_cont_pref.application_id ;


              -- change the API Name temporarily so that in case of unexpected error
              -- it is properly caught
              l_api_name := l_api_name||'-CREATE_CONTACT_PREFERENCE';

              hz_contact_preference_v2pub.create_contact_preference (
                                      p_init_msg_list          => FND_API.G_FALSE,
                                      p_contact_preference_rec => l_contact_preference_record,
                                      x_contact_preference_id  => l_contact_preference_id,
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data
                                      );

              -- set back the API name to original name
              l_api_name := l_api_name_1;

              IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('FND', 'FND_PII_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','CREATE_CONTACT_PREFERENCE');
                 fnd_message.set_token('P_API_NAME', l_api_name);
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
              END IF; -- end of x_return_status check
           END IF; -- end of check of r_cont_pref record

        ELSIF(p_option(i).user_option = 'O')
        THEN
           -- check to see if a opt-out record already exists . if not insert the record
           r_cont_pref := null;
           open c_cont_pref(l_party_id, p_option(i).purpose_code);
           fetch c_cont_pref into r_cont_pref;
           close c_cont_pref;

           IF(r_cont_pref.preference_code = 'DO_NOT')
           THEN
              -- do nothing as OPT-IN record already exists
              null;
           ELSIF(r_cont_pref.preference_code = 'DO')
           THEN
             l_all_flag := 'Y';
             -- delete the OPT-OUT record , in the unlikely case that it exisrs
             delete HZ_CONTACT_PREFERENCES pref
             where pref.contact_preference_id = r_cont_pref.contact_preference_id;
           ELSE
		      l_all_flag := 'Y';
            -- insert the OPT-IN record
            --l_contact_preference_record.contact_preference_id      := r_cont_pref.contact_preference_id;
              l_contact_preference_record.contact_level_table          := 'HZ_PARTIES';
              l_contact_preference_record.contact_level_table_id       := l_party_id;
              l_contact_preference_record.contact_type                 := 'PRIV_PREF';
              l_contact_preference_record.preference_code              := 'DO_NOT';
              l_contact_preference_record.preference_topic_type        := 'FND_BUSINESS_PURPOSES_B';
              --l_contact_preference_record.preference_topic_type_id     := p_option(i).purpose_code;
              l_contact_preference_record.preference_topic_type_code   := p_option(i).purpose_code;
              l_contact_preference_record.preference_start_date        := trunc(sysdate);
              l_contact_preference_record.preference_end_date          := null ;
              l_contact_preference_record.requested_by                 := l_requested_by;
              l_contact_preference_record.status                       := 'A' ;
              l_contact_preference_record.created_by_module            := 'FND Data Privacy' ;
              l_contact_preference_record.application_id               := 0; --r_cont_pref.application_id ;


              -- change the API Name temporarily so that in case of unexpected error
              -- it is properly caught
                l_api_name := l_api_name||'-CREATE_CONTACT_PREFERENCE';

                hz_contact_preference_v2pub.create_contact_preference (
                                      p_init_msg_list          => FND_API.G_FALSE,
                                      p_contact_preference_rec => l_contact_preference_record,
                                      x_contact_preference_id  => l_contact_preference_id,
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data
                                      );

              -- set back the API name to original name
                l_api_name := l_api_name_1;

                IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                   fnd_message.set_name('FND', 'FND_PII_GENERIC_API_ERROR');
                   fnd_message.set_token('P_PROC_NAME','CREATE_CONTACT_PREFERENCE');
                   fnd_message.set_token('P_API_NAME', l_api_name);
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
                 END IF; -- end of x_return_status check
             END IF; -- end of check of r_cont_pref record

        END IF; -- end of p_option.user_option check

      END IF; -- end of purpose_default_code check
    -- end if;
  END LOOP; -- end of loop for i from p_option.first to p_option.last

  -- check to see the l_all_flag. If value is Y then delete the record for opt-out-of-all-purposes button switch
  -- this flag is used to keep track that some change has been made to the user option for privacy preferences
  IF(l_all_flag = 'Y')
  THEN
       delete HZ_CONTACT_PREFERENCES pref
        WHERE pref.CONTACT_LEVEL_TABLE_ID      = l_party_id
          AND pref.CONTACT_LEVEL_TABLE         = 'HZ_PARTIES'
          AND pref.preference_topic_type       = 'FND_BUSINESS_PURPOSES_B'
          AND pref.contact_type                = 'PRIV_PREF'
          AND pref.preference_topic_type_code  = 'ALL';

  END IF;

END IF; -- end of l_party_id check

 fnd_message.set_name ('FND', 'FND_PII_CONFIRM_SAVE');
 FND_MSG_PUB.add;
 FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('FND', 'FND_PII_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );


END set_purpose_option;


END FND_UPDATE_USER_PREF_PUB;

/
