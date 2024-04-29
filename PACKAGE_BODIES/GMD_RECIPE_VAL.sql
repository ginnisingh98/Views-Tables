--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_VAL" AS
/* $Header: GMDRVALB.pls 120.0 2005/05/25 18:49:38 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_RECIPE_VAL';


/* Purpose: Validate entities within a recipe */
/* */
/*  RECIPE_EXISTS  in: id, name, version;   out: id */
/*  RECIPE_NAME  in: name, version, action_code; out: id */
/*  get_new_id   in: null;  out: next id in sequence */
/*  RECIPE_FOR_UPDATE  in: recipe_id; out: recipe_data, lock row */
/*  RECIPE_DESCRIPTION  in: description; out: success or failure */
/*  RECIPE_ORGN_CODE */
/*  PROCESS_LOSS_FOR_UPDATE  in:  recipe_id, orgn_code; out: lock row */
/*  RECIPE_CUST_EXISTS  in: recipe_id, customer_id;  out: success or failure */
/*  MODIFICATION HISTORY */
/*  Sukarna Reddy dt 03/14/02. Bug 2099699.  */
 /*   CHECK_ROUTING_VALIDITY :p_routing_id , p_recipe_status out: true or false */
/*  Person      Date    Comments */
/*  ---------   ------  ------------------------------------------ */
/*  LRJackson   08Nov2000  Created */

/* Standard parameters: */
/*   IN: */
/*   P_api_version   - standard parameter */
/*   P_init_msg_list - standard parameter (clear error msg list or not) */
/*   P_commit        - standard parameter.  Should be FND_API.G_FALSE */
/*                              This procedure does no insert/update/delete */
/*   P_validation_level - standard parameter */
/*   OUT: */
/*   x_return_status - standard parameter.  S=success,E=expected error, */
/*                                          U=unexpected error */
/*   x_msg_count     - standard parameter.  Num of messages generated */
/*   x_msg_data      - standard parameter.  If only1 msg, here it is */
/*   x_return_code   - num rows returned or SQLCODE (Database error number)*/

/* **************************************************************************/
/* NAME */
/*   recipe_exists */
/* DESCRIPTION */
/*   This procedure will check if given id or name and version exist in GMD_RECIPES. */
/*   If name and vers provided, id will be returned. */
/* PARAMETERS standard + recipe_id, recipe_no, recipe_vers */
/* RETURN VALUES standard + recipe_id */
/* 24Jul2001 L.R.Jackson   Added "AND recipe_no is null" clause.              */
/**************************************************************************** */

PROCEDURE recipe_exists
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_recipe_no        IN VARCHAR2,
                p_recipe_version   IN NUMBER,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_recipe_id        OUT NOCOPY  NUMBER)
IS
 /*   If recipe id alone is given                                 */
 /*     OR                                                        */
 /*   If recipe_no and recipe_version are given.                  */
 /*                                                               */
 /*   If all 3 are given, compare the recipe_id returned with the */
 /*     recipe_id given as parameter.                             */

     CURSOR get_record_with_recipe_id(vRecipe_id NUMBER) IS
        select recipe_id
          from gmd_recipes_b
         where recipe_id  = vRecipe_id;

--Gjha 27-Dec-2004 Bug 4073815 . Removed the Upper  of UPPER(recipe_no) to improve the performance. The uniqueness is
-- is to be maintained for case-sensitive Recipe_no and Recipe_version.
     CURSOR get_record_without_recipe_id(vRecipe_no    VARCHAR2
                                        ,vRecipe_version  NUMBER) IS
        select recipe_id
          from gmd_recipes_b
         where recipe_no =  vRecipe_no
         and   recipe_version = vRecipe_version;

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'RECIPE_EXISTS';
   l_api_version    CONSTANT  NUMBER  := 1.1;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete  */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_recipe_id IS NOT NULL) THEN
    OPEN  get_record_with_recipe_id(p_recipe_id);
    FETCH get_record_with_recipe_id into x_recipe_id;
      IF get_record_with_recipe_id%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_NOT_VALID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    CLOSE get_record_with_recipe_id;
  ELSE
    OPEN  get_record_without_recipe_id(p_recipe_no, p_recipe_version);
    FETCH get_record_without_recipe_id into x_recipe_id;
      IF get_record_without_recipe_id%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE_NOT_VALID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    CLOSE get_record_without_recipe_id;
  END IF;

  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   END recipe_exists;

/* ************************************************************************** */
/* NAME */
/*   recipe_name */
/* DESCRIPTION */
/*   This procedure will check if given name and version exist in GMD_RECIPES. */
/*   If action_code = I and name+vers does not exist, success returned. */
/*   If action_code = U and Nmae+vers exists, recipe_id will be returned */
/* PARAMETERS standard + recipe_no, recipe_vers, action_code=I(insert) or U(udpate) */
/* RETURN VALUES standard + recipe_id */
/**************************************************************************** */

PROCEDURE recipe_name
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_no        IN VARCHAR2,
                p_recipe_version   IN NUMBER,
                p_action_code      IN VARCHAR2 := 'U',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_recipe_id        OUT NOCOPY  NUMBER)
IS
     CURSOR get_record IS
        select recipe_id
          from gmd_recipes_b
         where recipe_no      = p_recipe_no
           and recipe_version = p_recipe_version;

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'RECIPE_NAME';
   l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete  */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  get_record;
  FETCH get_record into x_recipe_id;

  IF P_action_code = 'I' THEN
    IF get_record%FOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;  /* end if record not found  */
  ELSIF p_action_code = 'U' THEN
    IF get_record%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  ELSE
    RAISE fnd_api.g_exc_error;
  END IF;   /* end if action code is insert or update  */

  CLOSE get_record;

  /* no standard check of p_commit because no insert/update/delete */

  /*  standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   END recipe_name;

/* **************************************************************************/
/* NAME */
/*   get_new_id */
/* DESCRIPTION */
/*   This procedure will */
/* */
/* PARAMETERS (other than standard parameters) */
/* */
/* RETURN VALUES (other than standard return values) */
/*     recipe_id */
/* */
/* Person      Date       Comments */
/* ---------   ------     ------------------------------------------ */
/* LRJackson   14Nov2000  Created */
/**************************************************************************** */
PROCEDURE   get_new_id
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_recipe_id        OUT NOCOPY  NUMBER)
IS
     CURSOR get_new_id IS
        select gmd_recipe_id_s.NEXTVAL
          from dual;

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'GET_NEW_ID';
   l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete   */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  get_new_id;
  FETCH get_new_id into x_recipe_id;
  CLOSE get_new_id;

  /* no standard check of p_commit because no insert/update/delete  */
  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END get_new_id;


/* **************************************************************************/
/* NAME */
/*   recipe_for_update */
/* DESCRIPTION */
/*   This procedure will */
/* */
/* PARAMETERS (other than standard parameters) */
/* */
/* RETURN VALUES (other than standard return values) */
/*
/* Person      Date       Comments */
/* ---------   ------     ------------------------------------------ */
/* LRJackson   14Nov2000  Created */
/* LRJackson   27Dec2000  Updated parameters */
/**************************************************************************** */
PROCEDURE   recipe_for_update
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_last_update_date IN DATE,
                p_form_or_asynch   IN VARCHAR2 := 'A',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER)
IS
     CURSOR get_recipe_data IS
        select last_update_date
          from gmd_recipes
         where recipe_id        = p_recipe_id;

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'RECIPE_FOR_UPDATE';
   l_api_version    CONSTANT  NUMBER  := 1.0;
   l_update_date    DATE;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete  */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  get_recipe_data;
  FETCH get_recipe_data into l_update_date;
  IF get_recipe_data%NOTFOUND THEN
    RAISE fnd_api.g_exc_error;
  ELSE
    IF p_last_update_date is NULL OR l_update_date <> p_last_update_date THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      IF p_form_or_asynch = 'A' THEN
        NULL;
        /*  need to lock record here  */
      END IF;   /* end if this procedure called asynchronously  */
    END IF;     /* end if update dates do not match  */
  END IF;       /* end if record not found  */
  CLOSE get_recipe_data;

  /* no standard check of p_commit because no insert/update/delete  */
  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END  recipe_for_update;


/* **************************************************************************/
/* NAME */
/*   recipe_description */
/* DESCRIPTION */
/*   This procedure will */
/* */
/* PARAMETERS (other than standard parameters) */
/* */
/* RETURN VALUES (other than standard return values) */
/* */
/* Person      Date       Comments */
/* ---------   ------     ------------------------------------------ */
/* LRJackson   14Nov2000  Created */
/**************************************************************************** */
PROCEDURE   recipe_description
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_description IN VARCHAR2,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER)
IS

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'RECIPE_DESCRIPTION';
   l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete  */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_recipe_description IS NULL THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* no standard check of p_commit because no insert/update/delete  */
  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END  recipe_description;

/* **************************************************************************/
/* NAME */
/*   recipe_orgn_code */
/* DESCRIPTION */
/*   This procedure will validate that a given orgn_code is a plant or a lab */
/*   and that it is associated with the given user */
/* */
/* PARAMETERS (other than standard parametrs) */
/*     orgn_code, user_id, required_ind */
/* */
/* RETURN VALUES (other than standard return values) */
/* */
/* Person      Date       Comments */
/* ---------   ------     ------------------------------------------ */
/* LRJackson   21Dec2000  Created */
/**************************************************************************** */
PROCEDURE   recipe_orgn_code
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                g_orgn_id          IN NUMBER,
                g_user_id          IN NUMBER,
                p_required_ind     IN VARCHAR2 := 'N',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER,
                x_plant_ind        OUT NOCOPY  NUMBER,
		x_lab_ind          OUT NOCOPY  NUMBER)
IS
/*   do the following cursors in 2 steps (rather than combine the cursors into 1)  */
/*   so that error messages can be more specific    */

    l_resp_id		NUMBER(15) DEFAULT FND_PROFILE.VALUE('RESP_ID');

     CURSOR get_orgn_code IS
        select plant_ind, lab_ind
          from gmd_parameters_hdr
         where organization_id = g_orgn_id;

     CURSOR get_user_orgn (vresp_id NUMBER) IS
       SELECT 1
       FROM   org_access_view
       WHERE  responsibility_id = vresp_id
       AND    organization_id = g_orgn_id;


   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'RECIPE_ORGN_CODE';
   l_api_version    CONSTANT  NUMBER  := 1.0;
   v_temp           NUMBER;
BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete   */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                      l_api_name,    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_required_ind = 'Y' and g_orgn_id is NULL) THEN
    RAISE fnd_api.g_exc_error;
  ELSIF (p_required_ind = 'N' and g_orgn_id is not NULL) THEN
      /* if orgn code is null and orgn code is not required, then  */
      /* no further validation is necessary      */
    OPEN  get_orgn_code;
    FETCH get_orgn_code into x_plant_ind,x_lab_ind;
    IF get_orgn_code%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE get_orgn_code;

    OPEN get_user_orgn (l_resp_id);
    FETCH get_user_orgn into v_temp;
    IF get_user_orgn%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
      /*  (need an appropriate error message here for user not assoc with orgn)  */
    ELSE
      IF (x_plant_ind <> 1 AND x_lab_ind <> 1) THEN  --Krishna  conv
        RAISE FND_API.g_exc_error;
        /*  (need an appropriate error message here for not a plant or lab)  */

      END IF;  /* end if plant ind is plant or lab  */
    END IF;    /* end if user associated with this orgn  */

    CLOSE get_user_orgn;
  END IF;    /* end if orgn code is null or not  */

  /* no standard check of p_commit because no insert/update/delete  */
  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END  recipe_orgn_code;

/* **************************************************************************/
/* NAME */
/*   process_loss_for_update */
/* DESCRIPTION */
/*   This procedure will */
/* */
/* PARAMETERS (other than standard parameters) */
/* */
/* RETURN VALUES (other than standard return values) */
/* */
/* Person      Date       Comments */
/* ---------   ------     ------------------------------------------ */
/* LRJackson   14Nov2000  Created */
/**************************************************************************** */
PROCEDURE   process_loss_for_update
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_orgn_id          IN NUMBER,
                p_last_update_date IN DATE,
                p_form_or_asynch   IN VARCHAR2 := 'A',
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER)
IS
     CURSOR check_recipe_id IS
        select last_update_date
          from gmd_recipe_process_loss
         where recipe_id = p_recipe_id
           and organization_id = p_orgn_id;

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'PROCESS_LOSS_FOR_UPDATE';
   l_api_version    CONSTANT  NUMBER  := 1.0;
   l_update_date    DATE;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete  */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  check_recipe_id;
  FETCH check_recipe_id into l_update_date;
  IF check_recipe_id%NOTFOUND THEN
    RAISE fnd_api.g_exc_error;
  ELSE
    IF p_last_update_date is NULL OR l_update_date <> p_last_update_date THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      IF p_form_or_asynch = 'A' THEN
        NULL;
        /*  need to lock record here  */
      END IF;   /* end if this procedure called asynchronously */
    END IF;     /* end if update dates do not match  */
  END IF;       /* end if record not found  */

  CLOSE check_recipe_id;

  /* no standard check of p_commit because no insert/update/delete  */
  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END   process_loss_for_update;

/* **************************************************************************/
/* NAME */
/*   recipe_cust_exists */
/* DESCRIPTION */
/*   This procedure will check if given id or name and version exist in */
/*   GMD_RECIPE_CUSTOMERSS. */
/* PARAMETERS standard + recipe_id, customer_id */
/* RETURN VALUES standard */
/**************************************************************************** */

PROCEDURE recipe_cust_exists
              ( p_api_version      IN NUMBER,
                p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                p_recipe_id        IN NUMBER,
                p_customer_id      IN NUMBER,
                x_return_status    OUT NOCOPY  VARCHAR2,
                x_msg_count        OUT NOCOPY  NUMBER,
                x_msg_data         OUT NOCOPY  VARCHAR2,
                x_return_code      OUT NOCOPY  NUMBER)
IS
     CURSOR get_record IS
        select recipe_id
          from gmd_recipe_customers
         where  recipe_id   = p_recipe_id
           and  customer_id = p_customer_id;

   /*** Variables ***/
   l_api_name       CONSTANT  VARCHAR2(30) := 'RECIPE_CUST_EXISTS';
   l_api_version    CONSTANT  NUMBER  := 1.0;
   l_recipe_id      gmd_recipes.recipe_id%TYPE;

BEGIN
  /*  no SAVEPOINT needed because there is no insert/update/delete  */
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  get_record;
  FETCH get_record into l_recipe_id;

  IF get_record%NOTFOUND THEN
    RAISE fnd_api.g_exc_error;
  END IF;  /* end if record not found  */

  CLOSE get_record;

  /* no standard check of p_commit because no insert/update/delete  */

  /* standard call to get msge cnt, and if cnt is 1, get mesg info  */
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

    WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   END recipe_cust_exists;

 /* **************************************************************************
  NAME
    check_routing_validity
  DESCRIPTION
    This procedure will validate if routing attached to a recipe is of valid
    status or not.
      PARAMETERS   p_routing_id
                   p_recipe_status
   RETURN VALUES   TRUE - if valid
                   FALSE - If invalid
   author
   Sukarna Reddy bug 2099699. dt 03/14/02.
   Ravi S Reddy  bug 2402946. dt 06/24/02
                 Deleted status type 900 so that recipe can be created with
                 frozen routings.
  **************************************************************************** */


  FUNCTION check_routing_validity(p_routing_id    NUMBER,
                                  p_recipe_status VARCHAR2) RETURN BOOLEAN IS
  CURSOR Cur_rtstatus_vldty IS
    SELECT COUNT(*)
    FROM  gmd_routings_b h,gmd_status s
    WHERE h.routing_id = p_routing_id AND
          h.routing_status = s.status_code AND
          to_number(h.routing_status) >= to_number(p_recipe_status) AND
          -- Begin Bug#2402946 Ravi S Reddy
          -- Deleted Status_Type 900
          s.status_type NOT IN ('800','1000');
          -- End Bug#2402946
     l_count NUMBER := 0;
  BEGIN
    IF (p_routing_id IS NOT NULL) THEN
      OPEN Cur_rtstatus_vldty;
      FETCH Cur_rtstatus_vldty INTO l_count;
      CLOSE Cur_rtstatus_vldty;
      IF (l_count = 0) THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;
  END check_routing_validity;


  /*#####################################################
  # NAME
  #    validate_start_date
  # SYNOPSIS
  #    Proc validate_start_date
  # DESCRIPTION
  #    This procedure validates that start date is no earlier
  #    than any routing start date.
  # HISTORY
  #####################################################*/
  PROCEDURE validate_start_date (P_disp_start_date  Date,
                                 P_routing_start_date Date,
                                 x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'validate_start_date' ;
  BEGIN
    x_return_status := 'S';

    IF P_disp_start_date < P_routing_start_date THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_VALIDITY_DATE_IN_ROUT_DATE');
       FND_MSG_PUB.ADD;
       x_return_status := 'E';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END  validate_start_date;

  /*#####################################################
  # NAME
  #    validate_end_date
  # SYNOPSIS
  #    Proc validate_end_date
  # DESCRIPTION
  #    This procedure validates that end date is no later
  #    than any routing end date.
  #    Also validates date entered against sys max date.
  # HISTORY
  #####################################################*/
  PROCEDURE validate_end_date (P_end_date  Date,
                               P_routing_end_date Date,
                               x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'validate_end_date' ;
  BEGIN
    x_return_status := 'S';
    IF (P_end_date IS NOT NULL) AND
       (P_routing_end_date IS NOT NULL) AND
       (P_end_date > P_routing_end_date) THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_VALIDITY_DATE_IN_ROUT_DATE');
       FND_MSG_PUB.ADD;
       x_return_status := 'E';
    END IF;

    -- Routing end date is finite but Vr end date is infinite
    IF (P_routing_end_date IS NOT NULL) AND
       (P_end_date IS NULL) THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_VALIDITY_DATE_IN_ROUT_DATE');
       FND_MSG_PUB.ADD;
       x_return_status := 'E';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END  validate_end_date;


  /*#####################################################
  # NAME
  #    effective_dates
  # SYNOPSIS
  #    Proc effective_dates
  # DESCRIPTION
  #    Validates dates to be within proper ranges.
  # HISTORY
  #####################################################*/
  PROCEDURE effective_dates ( P_start_date DATE,
                              P_end_date DATE,
                              x_return_status OUT NOCOPY VARCHAR2)   IS
    l_api_name  VARCHAR2(100) := 'effective_dates' ;
  BEGIN
    x_return_status := 'S';

    IF (P_end_date IS NOT NULL AND P_start_date IS NOT NULL) THEN
      IF (P_end_date < P_start_date) THEN
        FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
        FND_MSG_PUB.ADD;
        x_return_status := 'E';
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END effective_dates;

/*###################################################################
  # NAME
  #    std_qty
  # SYNOPSIS
  #    proc std_qty
  #    Called from when-val-record trigger
  # DESCRIPTION
  #    Checks for std_qty is in between min_qty and max_qty
  #    Std qty cannot be negative
  #
  ###################################################################*/
  PROCEDURE std_qty(P_std_qty NUMBER,
                    P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'std_qty' ;
  BEGIN
    x_return_status := 'S';
    IF P_std_qty IS NOT NULL THEN
      IF (P_std_qty < P_min_qty
          OR P_std_qty > P_max_qty)
          OR P_std_qty <= 0  THEN
        IF P_std_qty <= 0  THEN
          FND_MESSAGE.SET_NAME('GMD','FM_INV_STD_QTY');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        ELSE
          FND_MESSAGE.SET_NAME('GMD','FM_INV_STD_RANGE');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        END IF;  -- end if std qty is the problem, or the range
      END IF;    -- end if std qty not within range
    END IF;      -- end if std qty is not null
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END std_qty;

  /*#####################################################
  # NAME
  #    max_qty
  # SYNOPSIS
  #    proc max_qty
  #    Called from when-val-record trigger
  # DESCRIPTION
  #    Checks for max_qty is greater than min_qty
  #
  #######################################################*/
  PROCEDURE max_qty(P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'max_qty' ;
  BEGIN
    x_return_status := 'S';
    IF P_max_qty IS NOT NULL THEN
      IF (P_max_qty < P_min_qty
           OR P_min_qty < 0) THEN
        IF P_min_qty < 0  THEN
          FND_MESSAGE.SET_NAME('GMD','FM_INV_MIN_QTY');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        ELSE
          FND_MESSAGE.SET_NAME('GMD','FM_INV_MIN_MAX');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        END IF;       -- end if qty is the problem, or the range
      END IF;         -- IF (P_max_qty < P_min_qty
    END IF;           -- IF P_max_qty IS NOT NULL
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END max_qty;


  /*#####################################################
  # NAME
  #    calc_inv_qtys
  # SYNOPSIS
  #    proc calc_inv_qtys
  #    Parms
  # DESCRIPTION
  #    Checks for item_uom with standard item UOM, if different
  #    Converts the quantity from the initial UOM to the
  #    final UOM.
  #######################################################*/
  PROCEDURE calc_inv_qtys (P_inv_item_um VARCHAR2,
                           P_item_um     VARCHAR2,
                           P_item_id     NUMBER,
                           P_min_qty     NUMBER,
                           P_max_qty     NUMBER,
                           X_inv_min_qty OUT NOCOPY NUMBER,
                           X_inv_max_qty OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2
                           ) IS
    l_api_name  VARCHAR2(100) := 'calc_inv_qtys' ;
  BEGIN
    x_return_status := 'S';

    IF P_inv_item_um = P_item_um THEN
      X_inv_min_qty := P_min_qty;
      X_inv_max_qty := P_max_qty;
    ELSE
     /*########################################################
       # Stored Procedure call made here for the UOM conversion
       # between two different UOM's
       #########################################################*/
       X_inv_min_qty := INV_CONVERT.inv_um_convert(item_id        => P_item_id
                                                  ,precision      => 5
                                                  ,from_quantity  => P_min_qty
                                                  ,from_unit      => P_item_um
                                                  ,to_unit        => P_inv_item_um
                                                  ,from_name      => NULL
                                                  ,to_name	  => NULL);

       X_inv_max_qty := INV_CONVERT.inv_um_convert(item_id        => P_item_id
                                                  ,precision      => 5
                                                  ,from_quantity  => P_max_qty
                                                  ,from_unit      => P_item_um
                                                  ,to_unit        => P_inv_item_um
                                                  ,from_name      => NULL
                                                  ,to_name	  => NULL);

    END IF;
    X_inv_min_qty := ROUND(X_inv_min_qty,5);
    X_inv_max_qty := ROUND(X_inv_max_qty,5);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END calc_inv_qtys;

  /*#####################################################
  # NAME
  #    calculate_process_loss
  # SYNOPSIS
  #    Proc calculate_process_loss
  # DESCRIPTION
  #    derives theoretical and planned process loss
  #####################################################*/
  PROCEDURE calculate_process_loss( V_assign 	IN	NUMBER DEFAULT 1
                                   ,P_vr_id   IN  NUMBER
                                   ,X_TPL      OUT NOCOPY NUMBER
                                   ,X_PPL      OUT NOCOPY NUMBER
                                   ,x_return_status OUT NOCOPY VARCHAR2) IS

    process_loss_rec    GMD_COMMON_VAL.process_loss_rec;
    l_process_loss      GMD_PROCESS_LOSS.process_loss%TYPE;
    l_recipe_theo_loss  GMD_PROCESS_LOSS.process_loss%TYPE;
    x_msg_cnt           NUMBER;
    x_msg_dat           VARCHAR2(2000);

    l_std_qty              gmd_recipe_validity_rules.std_qty%TYPE;
    l_detail_uom           gmd_recipe_validity_rules.detail_uom%TYPE;
    l_inventory_item_id    gmd_recipe_validity_rules.inventory_item_id%TYPE;
    l_organization_id      gmd_recipe_validity_rules.organization_id%TYPE;

    CURSOR get_other_vr_details(V_vr_id NUMBER) IS
      SELECT std_qty, inventory_item_id, detail_uom, organization_id
      FROM   gmd_recipe_validity_rules
      WHERE  recipe_validity_rule_id = V_vr_id;

    l_api_name  VARCHAR2(100) := 'calculate_process_loss' ;

  BEGIN
    x_return_status := 'S';

    OPEN  get_other_vr_details(p_vr_id);
    FETCH get_other_vr_details INTO l_std_qty, l_inventory_item_id, l_detail_uom, l_organization_id;
    CLOSE get_other_vr_details;

    process_loss_rec.validity_rule_id := p_vr_id;
    process_loss_rec.qty := l_std_qty;
    process_loss_rec.uom := l_detail_uom;
    process_loss_rec.organization_id := l_organization_id;
    process_loss_rec.inventory_item_id := l_inventory_item_id;

    gmd_common_val.calculate_process_loss(process_loss       => process_loss_rec,
					  Entity_type        => 'VALIDITY',
					  x_recipe_theo_loss => X_TPL,
                                          x_process_loss     => X_PPL,
                                          x_return_status    => x_return_status,
                                          x_msg_count        => X_msg_cnt,
                                          x_msg_data         => X_msg_dat);

    X_TPL := TRUNC(X_TPL,2);
    X_PPL := TRUNC(X_PPL,2);

    IF (V_assign = 1) THEN
      IF X_PPL IS NULL THEN
        X_PPL := X_TPL;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END calculate_process_loss;

  /*#####################################################
  # NAME
  #    check_for_duplicate
  # SYNOPSIS
  #    Proc check_for_duplicate
  #    Parms
  # DESCRIPTION
  #    check duplication of record
  #####################################################*/
 PROCEDURE check_for_duplicate(pRecipe_id NUMBER
                               ,pitem_id NUMBER
                               ,pOrgn_id NUMBER DEFAULT NULL
                               ,pRecipe_Use NUMBER
                               ,pPreference NUMBER
                               ,pstd_qty NUMBER
                               ,pmin_qty NUMBER
                               ,pmax_qty NUMBER
                               ,pinv_max_qty NUMBER
                               ,pinv_min_qty NUMBER
                               ,pitem_um VARCHAR2
                               ,pValidity_Rule_Status  VARCHAR2
                               ,pstart_date DATE
                               ,pend_date DATE DEFAULT NULL
                               ,pPlanned_process_loss NUMBER DEFAULT NULL
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ) IS
    CURSOR Cur_check_dup_upd IS
      SELECT recipe_validity_rule_id
      FROM   gmd_recipe_validity_rules
      WHERE  recipe_id         = pRecipe_id
       AND inventory_item_id       = pitem_id
       AND ((organization_id   = pOrgn_id)  OR
           (organization_id IS NULL AND pOrgn_id is NULL))
       AND recipe_use    = pRecipe_Use
       AND preference    = pPreference
       AND std_qty       = pstd_qty
       AND min_qty       = pmin_qty
       AND max_qty       = pmax_qty
       AND inv_max_qty   = pinv_max_qty
       AND inv_min_qty   = pinv_min_qty
       AND detail_uom    = pitem_um
       AND validity_rule_status  = pValidity_Rule_status
       AND ((pPlanned_process_loss IS NULL AND Planned_process_loss IS NULL) OR
            (planned_process_loss = pPlanned_process_loss))
       AND start_date = pstart_date
       AND ((end_date  = pend_date)  OR (end_date is NULL and pend_date is NULL));

    l_api_name  VARCHAR2(100) := 'check_for_duplicate' ;
  BEGIN
    x_return_status := 'S';
    FOR VR_dup_rec IN Cur_check_dup_upd LOOP
      FND_MESSAGE.SET_NAME('GMD','GMD_DUP_VR_EXIST');
      FND_MSG_PUB.ADD;
      x_return_status := 'E';
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END check_for_duplicate;


END;  /* Package Body GMD_RECIPE_VAL  */

/
