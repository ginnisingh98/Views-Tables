--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_EFFECTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_EFFECTIVITY_PVT" AS
/* $Header: GMDVFMEB.pls 115.12 2002/10/24 21:16:26 santunes noship $ */

   G_PKG_NAME CONSTANT 	VARCHAR2(30)  	:= 'GMD_FORMULA_EFFECTIVITY_PVT';

  /* ============================================= */
  /* Procedure: */
  /*   Insert_FormulaEffectivity */

  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for */
  /*   inserting a formula effectivity. */
  /* HISTORY                            */
  /*   Mohit Kapoor 10-May-2002 Bug 2186284  */
  /*      Modified the insert statement such that the start_date */
  /*      and end_date are inserted without timestamp.  */
  /* ============================================= */

     PROCEDURE Insert_FormulaEffectivity
     (  p_api_version           IN      NUMBER                                  ,
        p_init_msg_list         IN      varchar2                                ,
        p_commit                IN      varchar2                                ,
        x_return_status         OUT NOCOPY     varchar2                                ,
        x_msg_count             OUT NOCOPY     NUMBER                                  ,
        x_msg_data              OUT NOCOPY     VARCHAR2                                ,
        p_formula_effectivity_rec    IN      fm_form_eff%ROWTYPE
     )
     IS
        /*  Local Variables definitions */
        l_api_name              CONSTANT    VARCHAR2(30)  := 'INSERT_FORMULAEFFECTIVITY';
        l_api_version           CONSTANT    NUMBER        := 1.0;

     BEGIN
        /*  Define Savepoint */
        SAVEPOINT  Insert_FormulaEffectivity_PVT;

        /*  Standard Check for API compatibility */
        IF NOT FND_API.Compatible_API_Call  (   l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME  )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

        /*  Initialize message list if p_init_msg_list is set to TRUE */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        /*  Initialize API return status to success */
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* API Body */
	/* Later on this insert should be changed to */
	/* make insert on business view as opposed to tables directly. */

   /* Bug 2186284 Mohit Kapoor */
   /* Modified p_formula_effectivity_rec.end_date and  */
   /* p_formula_effectivity_rec.start_date to use      */
   /* trunc(p_formula_effectivity_rec.end_date),       */
   /* trunc(p_formula_effectivity_rec.start_date)      */
      INSERT INTO fm_form_eff
        (fmeff_id, orgn_code,
         item_id, formula_use,
         end_date, start_date,
         inv_min_qty, inv_max_qty,
         min_qty, max_qty,
         std_qty, item_um,
         preference, routing_id,
         formula_id, cust_id,
         trans_cnt, text_code,
         delete_mark, created_by,
         creation_date, last_update_date,
         last_updated_by, last_update_login)
      VALUES
        (p_formula_effectivity_rec.fmeff_id, p_formula_effectivity_rec.orgn_code,
         p_formula_effectivity_rec.item_id, p_formula_effectivity_rec.formula_use,
         TRUNC(p_formula_effectivity_rec.end_date), TRUNC(p_formula_effectivity_rec.start_date),
         p_formula_effectivity_rec.inv_min_qty, p_formula_effectivity_rec.inv_max_qty,
         p_formula_effectivity_rec.min_qty, p_formula_effectivity_rec.max_qty,
         p_formula_effectivity_rec.std_qty, p_formula_effectivity_rec.item_um,
         p_formula_effectivity_rec.preference, p_formula_effectivity_rec.routing_id,
         p_formula_effectivity_rec.formula_id, p_formula_effectivity_rec.cust_id,
         p_formula_effectivity_rec.trans_cnt, p_formula_effectivity_rec.text_code,
         p_formula_effectivity_rec.delete_mark, p_formula_effectivity_rec.created_by,
         p_formula_effectivity_rec.creation_date, p_formula_effectivity_rec.last_update_date,
         p_formula_effectivity_rec.last_updated_by, p_formula_effectivity_rec.last_update_login);

      IF(SQL%ROWCOUNT = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

	/* END API Body */

        /* Check if p_commit is set to TRUE */
        IF FND_API.To_Boolean( p_commit ) THEN
                Commit;
        END IF;

        /*  Get the message count and information */
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );


     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to Insert_FormulaEffectivity_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK to Insert_FormulaEffectivity_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

        WHEN OTHERS THEN
                ROLLBACK to Insert_FormulaEffectivity_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

  END Insert_FormulaEffectivity;



  /* ============================================= */
  /* Procedure: */
  /*   Update_FormulaEffectivity */

  /* DESCRIPTION: */
  /*   This PL/SQL procedure is responsible for */
  /*   updating a formula effectivity. */
  /* HISTORY:  */
  /* RajaSekhar   03/02/2002 BUG#2202559 */
  /* Modified the code to update the effective  */
  /* END_DATE of the frozen formula  */
  /* Mohit Kapoor 10-May-2002 Bug 2186284     */
  /*   Modified the update statement such that the start_date  */
  /*   and end_dates are updated without timestamp. */
  /* K. RajaSekhar Reddy 10/04/2002 BUG#2583665  */
  /*   Modified IF statement to update the formula effectivity record  */
  /*   with the existing orgn_code, if it's value is not passed or passed as null.  */
  /* ============================================= */

     PROCEDURE Update_FormulaEffectivity
     (  p_api_version           IN      NUMBER                                  ,
        p_init_msg_list         IN      VARCHAR2                                ,
        p_commit                IN      VARCHAR2                                ,
        x_return_status         OUT NOCOPY     VARCHAR2                                ,
        x_msg_count             OUT NOCOPY     NUMBER                                  ,
        x_msg_data              OUT NOCOPY     VARCHAR2                                ,
        p_formula_effectivity_rec    IN      fm_form_eff%ROWTYPE
     )
     IS

        /*  Local Variables definitions */
        l_api_name              CONSTANT    VARCHAR2(30)  := 'UPDATE_FORMULAEFFECTIVITY';
        l_api_version           CONSTANT    NUMBER        := 1.0;
	l_fm_eff_rec		fm_form_eff%ROWTYPE;

	l_orgn_code	fm_form_eff.orgn_code%TYPE;
        l_formula_use    fm_form_eff.formula_use%TYPE;
        l_end_date        fm_form_eff.end_date%TYPE;
        l_start_date      fm_form_eff.start_date%TYPE;
        l_inv_min_qty      fm_form_eff.inv_min_qty%TYPE;
        l_inv_max_qty      fm_form_eff.inv_max_qty%TYPE;
        l_min_qty          fm_form_eff.min_qty%TYPE;
        l_max_qty          fm_form_eff.max_qty%TYPE;
        l_std_qty           fm_form_eff.std_qty%TYPE;
        l_item_um          fm_form_eff.item_um%TYPE;
        l_preference         fm_form_eff.preference%TYPE;

	/* define cursor */
	CURSOR get_record(vfmeff_id NUMBER) IS
	SELECT *
	FROM 	fm_form_eff
	WHERE	fmeff_id = vfmeff_id;

     BEGIN
        /*  Define Savepoint */
        SAVEPOINT  Update_FormulaEffectivity_PVT;

        /*  Standard Check for API compatibility */
        IF NOT FND_API.Compatible_API_Call  (   l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME  )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /*  Initialize message list if p_init_msg_list is set to TRUE */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        /*  Initialize API return status to success */
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /*  API body */
	/*  Later on to be changed to update a business view */
	/*  and not a table. */

	/*  Certain vaildation to be performed. */
	OPEN get_record(p_formula_effectivity_rec.fmeff_id);
	FETCH get_record INTO l_fm_eff_rec;

	/* If any of the required fields are passed in as null set them back to the  */
	/* original value */
	/* BEGIN BUG#2583665 RajaSekhar  */
	/* = FND_API.G_MISS_CHAR is replaced by IS NULL in the below IF condition */
	IF (p_formula_effectivity_rec.orgn_code IS NULL) THEN
		l_orgn_code := l_fm_eff_rec.orgn_code ;
	ELSE
		l_orgn_code := p_formula_effectivity_rec.orgn_code;
	END IF;
	/* END BUG#2583665*/

	/* Formula use */
        IF (p_formula_effectivity_rec.formula_use IS NULL) THEN
                l_formula_use := l_fm_eff_rec.formula_use;
        ELSE
                l_formula_use := p_formula_effectivity_rec.formula_use;
        END IF;

	/* Start date */
        IF (p_formula_effectivity_rec.start_date IS NULL) THEN
                l_start_date := l_fm_eff_rec.start_date;
        ELSE
                l_start_date := p_formula_effectivity_rec.start_date;
        END IF;

        IF (p_formula_effectivity_rec.end_date IS NULL) THEN
                l_end_date := l_fm_eff_rec.end_date;
        ELSE
                l_end_date := p_formula_effectivity_rec.end_date;
        END IF;

        IF (p_formula_effectivity_rec.inv_min_qty IS NULL) THEN
                l_inv_min_qty := l_fm_eff_rec.inv_min_qty;
        ELSE
                l_inv_min_qty := p_formula_effectivity_rec.inv_min_qty;
        END IF;

        IF (p_formula_effectivity_rec.inv_max_qty IS NULL) THEN
                l_inv_max_qty := l_fm_eff_rec.inv_max_qty;
        ELSE
                l_inv_max_qty := p_formula_effectivity_rec.inv_max_qty;
        END IF;

        IF (p_formula_effectivity_rec.min_qty IS NULL) THEN
                l_min_qty := l_fm_eff_rec.min_qty;
        ELSE
                l_min_qty := p_formula_effectivity_rec.min_qty;
        END IF;

        IF (p_formula_effectivity_rec.max_qty IS NULL) THEN
                l_max_qty := l_fm_eff_rec.max_qty;
        ELSE
                l_max_qty := p_formula_effectivity_rec.max_qty;
        END IF;

        IF (p_formula_effectivity_rec.std_qty IS NULL) THEN
                l_std_qty := l_fm_eff_rec.std_qty;
        ELSE
                l_std_qty := p_formula_effectivity_rec.std_qty;
        END IF;

        IF (p_formula_effectivity_rec.preference IS NULL) THEN
                l_preference := l_fm_eff_rec.preference;
        ELSE
                l_preference := p_formula_effectivity_rec.preference;
        END IF;

        IF (p_formula_effectivity_rec.item_um IS NULL) THEN
                l_item_um := l_fm_eff_rec.item_um;
        ELSE
                l_item_um := p_formula_effectivity_rec.item_um;
        END IF;

      /* Bug 2186284 Mohit Kapoor */
      /* Modified l_end_date and l_start_date to use */
      /* TRUNC(l_end_date), TRUNC(l_start_date)     */
      UPDATE fm_form_eff SET
        orgn_code          = l_orgn_code,
        formula_use        = l_formula_use,
        end_date           = TRUNC(l_end_date),
        start_date         = TRUNC(l_start_date),
        inv_min_qty        = l_inv_min_qty,
        inv_max_qty        = l_inv_max_qty,
        min_qty            = l_min_qty,
        max_qty            = l_max_qty,
        std_qty            = l_std_qty,
        item_um            = l_item_um,
        preference         = l_preference,
        --BEGIN BUG#2202559 RajaSekhar
        --The columns creation_date and created _by are commented as update
        --statement should not overwrite them. DECODE is used to update the column
        --with the database value if it is not passed in PL/SQL record.
        routing_id         = DECODE(p_formula_effectivity_rec.routing_id, NULL, routing_id, p_formula_effectivity_rec.routing_id),
        cust_id            = DECODE(p_formula_effectivity_rec.cust_id, NULL, cust_id, p_formula_effectivity_rec.cust_id),
        --creation_date	   = p_formula_effectivity_rec.creation_date,
        --created_by	   = p_formula_effectivity_rec.created_by,
        last_update_date   = p_formula_effectivity_rec.last_update_date,
        last_updated_by    = p_formula_effectivity_rec.last_updated_by,
        delete_mark	   = DECODE(p_formula_effectivity_rec.delete_mark, NULL, delete_mark, p_formula_effectivity_rec.delete_mark),
        text_code	   = DECODE(p_formula_effectivity_rec.text_code, NULL, text_code, p_formula_effectivity_rec.text_code),
        trans_cnt	   = DECODE(p_formula_effectivity_rec.trans_cnt, NULL, trans_cnt, p_formula_effectivity_rec.trans_cnt)
        --END BUG#2202559
      WHERE
        fmeff_id = p_formula_effectivity_rec.fmeff_id;

      IF(SQL%ROWCOUNT = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;


	/* End API body */

        /* Check if p_commit is set to TRUE */
        IF FND_API.To_Boolean( p_commit ) THEN
                Commit;
        END IF;

        /*  Get the message count and information */
        FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data   );


     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to Update_FormulaEffectivity_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK to Update_FormulaEffectivity_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

        WHEN OTHERS THEN
                ROLLBACK to Update_FormulaEffectivity_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

  END Update_FormulaEffectivity;


END GMD_FORMULA_EFFECTIVITY_PVT;

/
