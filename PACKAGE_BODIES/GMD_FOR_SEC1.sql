--------------------------------------------------------
--  DDL for Package Body GMD_FOR_SEC1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FOR_SEC1" AS
/* $Header: GMDFSPRB.pls 120.1 2005/07/26 14:02:58 txdaniel noship $ */

PROCEDURE sec_prof_form(
        p_api_version           IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
        before_sec_prof_rec     IN          gmd_security_profiles%ROWTYPE,
        sec_prof_rec            IN          gmd_security_profiles%ROWTYPE,
        p_formula_id            IN          NUMBER,
        p_db_action_ind         IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2,
        x_return_code           OUT NOCOPY  NUMBER
)
/********************************************************************************************************************************
 Change History
 Who       When         What
 nsrivast  16-JAN-2004   Replace the existing code with code to reflect the new behavior w.r.t. bug 3344335.
                         The procedure has been modified so that it no longer inserts records
                         to GMD_FORMULA_SECURITY table if the assignment type is 'AUTOMATIC'.

                         When called from  Security Profile form (p_formula_id is NULL)
                         1) INSERT :- New record is added in GMD_SECURITY_PROFILES
                         2) DELETE :- Delete records from GMD_SECURITY_PROFILES   and   Delete corresponding records
                                      from GMD_FORMULA_SECURITY  if the assignment type is 'MANUAL'
                         3) UPDATE :- Update records in GMD_SECURITY_PROFILES
                                      Delete the records from GMD_FORMULA_SECURITY if the previous assignment type was 'MANUAL'

                         When called from the Formula form for a specific formula (p_formula_id is NOT NULL)
                         1) INSERT :- Create records in GMD_FORMULA_SECURITY one for each security profile, with
                                      'Manual' assign type, associated with the Organisation with which the formula is associated.
                         2) DELETE :- Delete the records in GMD_FORMULA_SECURITY   associated with that Formula_id
                         3) UPDATE :-  Update the columns in GMD_FORMULA_SECURITY for the formula id.
************************************************************************************************************************************/
IS


--
--    Cursor cur_form_1 is used when inserting record into GMD_FORMULA_SECURITY wity assigned type Manual for a specific Formula
--

   CURSOR cur_form_1 IS
   SELECT  formula_id,
           owner_organization_id,
           last_updated_by FROM  fm_form_mst_b
                           WHERE formula_id = p_formula_id
                           AND   owner_organization_id  = sec_prof_rec.organization_id;

   get_rec_1               cur_form_1%ROWTYPE ;
   x_resp_id               NUMBER;
   x_user_id               NUMBER;
   v_resp_id               NUMBER;
BEGIN

    x_return_status := 'S';
   SELECT fnd_global.resp_id INTO x_resp_id FROM dual;
   SELECT fnd_global.user_id INTO x_user_id FROM dual;

    SELECT responsibility_id   INTO v_resp_id
    FROM   fnd_responsibility
    WHERE  responsibility_key = 'GMD_SECURITY_PROFILE_MGR';

    fnd_global.apps_initialize (2060, v_resp_id , 552);

--
--   GMD_SECURITY_PROFILE table updated when called from GMDFMSCP form , Formula Id is always NULL
--
   IF  NVL(p_formula_id,0) = 0
   THEN
       --Creates new records in GMD_SECURITY_PROFILES table when db action is insert.
       IF   p_db_action_ind = 'I'
       THEN
        INSERT INTO GMD_SECURITY_PROFILES       (
          security_profile_id,
          object_type,
          organization_id,
          other_organization_id,
          user_id,
          responsibility_id,
          access_type_ind,
          assign_method_ind,
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login   )
         VALUES    (
          sec_prof_rec.security_profile_id,
          'F',
          sec_prof_rec.organization_id,
          sec_prof_rec.other_organization_id,
          sec_prof_rec.user_id,
          sec_prof_rec.responsibility_id,
          sec_prof_rec.access_type_ind,
          sec_prof_rec.assign_method_ind,
          sec_prof_rec.created_by,
          sec_prof_rec.creation_date,
          sec_prof_rec.last_update_date,
          sec_prof_rec.last_updated_by,
          sec_prof_rec.last_update_login);
       ELSE
          -- Delete the records from fromula security if the old assignment type was 'MANUAL'
          -- and action is delete/update
           IF before_sec_prof_rec.assign_method_ind='M'  THEN
               DELETE FROM GMD_FORMULA_SECURITY
               WHERE  organization_id            = before_sec_prof_rec.organization_id
                  AND   NVL(user_id,-1)           = NVL(before_sec_prof_rec.user_id,-1)
                  AND   NVL(responsibility_id,0) = NVL(before_sec_prof_rec.responsibility_id,0)
                  AND   NVL(other_organization_id, -1)     = NVL(before_sec_prof_rec.other_organization_id, -1) ;
            END IF;

           -- If db action is delete then delete all old profiles from Security Profile table.
           IF p_db_action_ind = 'D' THEN
            DELETE FROM GMD_SECURITY_PROFILES
            WHERE  organization_id = sec_prof_rec.organization_id
                    AND   NVL(user_id,-1)           = NVL(sec_prof_rec.user_id,-1)
                    AND   NVL(responsibility_id,0) = NVL(sec_prof_rec.responsibility_id,0)
                    AND   NVL(other_organization_id, -1)     = NVL(sec_prof_rec.other_organization_id, -1);

           -- Update the Security Profile table with new data when db action is Update.
           ELSE
             UPDATE GMD_SECURITY_PROFILES
             SET      organization_id       = sec_prof_rec.organization_id,
                      other_organization_id = sec_prof_rec.other_organization_id,
                      user_id               = sec_prof_rec.user_id,
                      responsibility_id     = sec_prof_rec.responsibility_id,
                      access_type_ind       = sec_prof_rec.access_type_ind,
                      assign_method_ind     = sec_prof_rec.assign_method_ind,
                      last_update_date      = SYSDATE,
                      last_updated_by       = sec_prof_rec.last_updated_by
             WHERE  organization_id              = before_sec_prof_rec.organization_id
                  AND   NVL(user_id,-1)           = NVL(before_sec_prof_rec.user_id,-1)
                  AND   NVL(responsibility_id,0) = NVL(before_sec_prof_rec.responsibility_id,0)
                  AND   NVL(other_organization_id, -1)  = NVL(before_sec_prof_rec.other_organization_id, -1);
           END IF ;
       END IF;

   --Called from Manual Entry on formula for a specific formula.
   ELSE
       --Creates new records in GMD_FORMULA_SECURITY table when db action is insert.
      IF p_db_action_ind = 'I' THEN
         OPEN cur_form_1 ;
         FETCH cur_form_1 INTO get_rec_1;
         IF cur_form_1%FOUND THEN
            INSERT INTO GMD_FORMULA_SECURITY (
                                formula_security_id,
                                formula_id,
                                access_type_ind,
                                organization_id,
                                user_id,
                                responsibility_id,
                                other_organization_id,
                                created_by,
                                creation_date,
                                last_update_date,
                                last_updated_by)
                 VALUES  (
                        gmd_formula_security_id_s.NEXTVAL,
                        get_rec_1.formula_id,
                        sec_prof_rec.access_type_ind,
                        get_rec_1.owner_organization_id,
                        sec_prof_rec.user_id,
                        sec_prof_rec.responsibility_id,
                        sec_prof_rec.other_organization_id,
                        get_rec_1.last_updated_by,
                        SYSDATE,
                        SYSDATE,
                        get_rec_1.last_updated_by);
         END IF;
        CLOSE cur_form_1;
      -- If db action is delete then delete all old profiles from Formula Security table.
      ELSIF  p_db_action_ind = 'D' THEN
            DELETE FROM GMD_FORMULA_SECURITY
            WHERE organization_id = sec_prof_rec.organization_id
                    AND   NVL(user_id,-1)           = NVL(sec_prof_rec.user_id,-1)
                    AND   NVL(responsibility_id,0) = NVL(sec_prof_rec.responsibility_id,0)
                    AND   NVL(other_organization_id, -1)     = NVL(sec_prof_rec.other_organization_id, -1)
                    AND  formula_id                = p_formula_id;
     ELSE    -- Update the Formula Security table with new data when db action is Update.
             UPDATE GMD_FORMULA_SECURITY
                SET organization_id       = sec_prof_rec.organization_id,
                    user_id               =  sec_prof_rec.user_id,
                    responsibility_id     = sec_prof_rec.responsibility_id,
                    other_organization_id = sec_prof_rec.other_organization_id,
                    last_update_date      = SYSDATE,
                    last_updated_by       = sec_prof_rec.last_updated_by
                 WHERE organization_id             = before_sec_prof_rec.organization_id
                    AND   NVL(user_id,-1)           = NVL(before_sec_prof_rec.user_id,-1)
                    AND   NVL(responsibility_id,0) = NVL(before_sec_prof_rec.responsibility_id,0)
                    AND   NVL(other_organization_id, -1) = NVL(before_sec_prof_rec.other_organization_id, -1)
                    AND   formula_id               = p_formula_id ;
      END IF;
  END IF;
 fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
 /*standard call to get msge cnt, and if cnt is 1, get mesg info*/
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN OTHERS THEN
      fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                   P_data  => x_msg_data);
END sec_prof_form ;
END GMD_FOR_SEC1;


/
