--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_SECURITY_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_SECURITY_ACCESS" AS
/* $Header: GMDFSFMB.pls 120.1 2005/08/04 09:28:21 txdaniel noship $ */

PROCEDURE secure_formula_access  ( p_organization_id  IN NUMBER,
                                   p_formula_id IN NUMBER )  IS
   l_organization_id         NUMBER(15);
   l_formula_id              NUMBER(15);
   x_return_status           VARCHAR2  (200)     ;
   x_msg_count               NUMBER     ;
   x_msg_data                VARCHAR2 (2000)     ;
   x_return_code             NUMBER;
   v_resp_id                 NUMBER;
   x_resp_id                 NUMBER;
   x_user_id                 NUMBER;

   CURSOR c_manual_formulas IS
     SELECT user_id, responsibility_id, other_organization_id
     FROM  GMD_formula_security
     WHERE organization_id = p_organization_id
     AND   formula_id = p_formula_id;
BEGIN

  DELETE FROM gmd_formula_security_temp;

  COMMIT;

  x_resp_id := fnd_global.resp_id;
  x_user_id := fnd_global.user_id;


  SELECT responsibility_id INTO v_resp_id
  FROM   fnd_responsibility
  WHERE  responsibility_key = 'GMD_SECURITY_PROFILE_MGR';

  -- fnd_global.apps_initialize (2060, v_resp_id , 552);
  l_organization_id := p_organization_id;
  l_formula_id := p_formula_id;

  INSERT INTO gmd_formula_security_temp( assign_method_ind,
                                         activated_ind,
                                         access_type_ind,
                                         organization_id,
                                         user_id,
                                         responsibility_id,
                                         other_organization_id)
  SELECT p.assign_method_ind,
         'N',
         p.access_type_ind,
         p.organization_id,
         p.user_id,
         p.responsibility_id,
         p.other_organization_id
  FROM  gmd_security_profiles p
  WHERE organization_id = l_organization_id
  AND assign_method_ind = 'M'
  --Added following clause to avoid duplicate records w.r.t. bug 3495409
  AND NOT EXISTS
     ( SELECT 1 FROM GMD_formula_security fs
       WHERE fs.formula_id                 = l_formula_id
       AND   fs.organization_id            = p.organization_id
       AND   NVL(fs.user_id,-1)            = NVL(p.user_id,-1)
       AND   NVL(fs.responsibility_id,-1)  = NVL(p.responsibility_id,-1)
       AND   ((fs.other_organization_id = p.other_organization_id) OR
              (fs.other_organization_id IS NULL AND p.other_organization_id IS NULL))
      );

   FOR l_users IN c_manual_formulas
   LOOP
     IF l_users.other_organization_id IS NULL THEN
           UPDATE GMD_formula_security_temp
           SET    activated_ind   = 'A'
           WHERE  user_id         = l_users.user_id
           AND    organization_id = p_organization_id
           AND    other_organization_id IS NULL;

           UPDATE GMD_formula_security_temp
           SET    activated_ind     = 'A'
           WHERE  responsibility_id = l_users.responsibility_id
           AND    organization_id   = p_organization_id
           AND    other_organization_id IS NULL;
   ELSE
           UPDATE GMD_formula_security_temp
           SET    activated_ind = 'A'
           WHERE  user_id       = l_users.user_id
           AND    organization_id = p_organization_id
           AND    other_organization_id = l_users.other_organization_id;

           UPDATE GMD_formula_security_temp
           SET    activated_ind     = 'A'
           WHERE  responsibility_id = l_users.responsibility_id
           AND    organization_id   = p_organization_id
           AND    other_organization_id = l_users.other_organization_id;

   END IF;
 END LOOP;

 INSERT INTO gmd_formula_security_temp( formula_id,
                                        assign_method_ind,
                                        activated_ind,
                                        access_type_ind,
                                        organization_id,
                                        user_id,
                                        responsibility_id,
                                        other_organization_id)
  SELECT p.formula_id,
         'M', --Modified 'A' to 'M' w.r.t. bug 3495409
         'A',
         p.access_type_ind,
         p.organization_id,
         p.user_id,
         p.responsibility_id,
         p.other_organization_id
  FROM  gmd_formula_security p
  WHERE organization_id = l_organization_id
  AND   formula_id = l_formula_id;

  COMMIT;
--  fnd_global.apps_initialize (x_user_id, x_resp_id , 552);

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     -- fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     -- fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN OTHERS THEN
      -- fnd_global.apps_initialize (x_user_id, x_resp_id , 552);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                   P_data  => x_msg_data);

END secure_formula_access;
END gmd_formula_security_access ;


/
