--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_DETAIL_PVT" AS
/* $Header: GMDVFMDB.pls 120.3.12010000.1 2008/07/24 10:01:38 appldev ship $ */

   G_PKG_NAME CONSTANT  VARCHAR2(30)    := 'GMD_FORMULA_DETAIL_PVT';

   --Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Insert_FormulaDetail                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for                               */
  /*   inserting a formula detail.                                            */
  /* HISTORY:                                                                 */
  /*    Kapil ME Bug# 5716318 - Added the new Percentage Fields for Auto -Prod*/
  /*                            ME.                                           */
  /* ======================================================================== */
  PROCEDURE Insert_FormulaDetail
  (  p_api_version          IN          NUMBER
     ,p_init_msg_list       IN          VARCHAR2
     ,p_commit              IN          VARCHAR2
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
     ,p_formula_detail_rec  IN          fm_matl_dtl%ROWTYPE
  )
  IS
     /*  Local Variables definitions */
     l_api_name      CONSTANT    VARCHAR2(30)  := 'INSERT_FORMULADETAIL';
     l_api_version   CONSTANT    NUMBER        := 1.0;
     X_msg_cnt       NUMBER;
     X_msg_dat       VARCHAR2(100);
     X_status        VARCHAR2(1);
     l_product_qty   NUMBER;
     l_ing_qty       NUMBER;
     l_uom           mtl_units_of_measure.unit_of_measure%TYPE;

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Insert_FormulaDetail_PVT;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call( l_api_version
                                         ,p_api_version
                                         ,l_api_name
                                         ,G_PKG_NAME  )
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     /* Initialize API return status to success */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* API Body */
     /* Later on this insert should be changed to */
     /* make insert on business view as opposed to tables directly. */

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('    ');
       END IF;

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula detail Pvt - About to insert formulaline id = '
                  ||p_formula_detail_rec.formulaline_id);
     END IF;

     INSERT INTO fm_matl_dtl
       (formulaline_id,
        formula_id,
        line_type,
        line_no,
        inventory_item_id,
	organization_id,
	revision,
        qty,
        detail_uom,
        release_type,
        scrap_factor,
        scale_type,
        cost_alloc,
        phantom_type,
        buffer_ind,
        rework_type,
        text_code,
        tpformula_id,
        iaformula_id,
        scale_multiple,
        contribute_yield_ind,
        scale_uom,
        contribute_step_qty_ind ,
        scale_rounding_variance,
        rounding_direction,
        /*Bug 2509076 - Thomas Daniel QM Integration */
        by_product_type,
        ingredient_end_date, --Bug 4479101
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        attribute1, attribute2,
        attribute3, attribute4,
        attribute5, attribute6,
        attribute7, attribute8,
        attribute9, attribute10,
        attribute11, attribute12,
        attribute13, attribute14,
        attribute15, attribute16,
        attribute17, attribute18,
        attribute19, attribute20,
        attribute21, attribute22,
        attribute23, attribute24,
        attribute25, attribute26,
        attribute27, attribute28,
        attribute29, attribute30,
        attribute_category,
        prod_percent)
     VALUES
       (p_formula_detail_rec.formulaline_id,
        p_formula_detail_rec.formula_id,
        p_formula_detail_rec.line_type,
        p_formula_detail_rec.line_no ,
        p_formula_detail_rec.inventory_item_id,
	p_formula_detail_rec.organization_id,
        p_formula_detail_rec.revision,
        p_formula_detail_rec.qty,
        p_formula_detail_rec.detail_uom,
        p_formula_detail_rec.release_type,
        p_formula_detail_rec.scrap_factor,
        p_formula_detail_rec.scale_type,
        p_formula_detail_rec.cost_alloc,
        p_formula_detail_rec.phantom_type,
        p_formula_detail_rec.buffer_ind,
        p_formula_detail_rec.rework_type,
        p_formula_detail_rec.text_code,
        p_formula_detail_rec.tpformula_id,
        p_formula_detail_rec.iaformula_id,
        p_formula_detail_rec.scale_multiple,
        p_formula_detail_rec.contribute_yield_ind,
        p_formula_detail_rec.scale_uom,
        p_formula_detail_rec.contribute_step_qty_ind ,
        p_formula_detail_rec.scale_rounding_variance  ,
        p_formula_detail_rec.rounding_direction  ,
        /*Bug 2509076 - Thomas Daniel  QM Integration */
        p_formula_detail_rec.by_product_type,
        p_formula_detail_rec.ingredient_end_date, --Bug 4479101
        p_formula_detail_rec.created_by,
        p_formula_detail_rec.creation_date,
        p_formula_detail_rec.last_update_date,
        p_formula_detail_rec.last_updated_by,
        p_formula_detail_rec.last_update_login,
        p_formula_detail_rec.attribute1, p_formula_detail_rec.attribute2,
        p_formula_detail_rec.attribute3, p_formula_detail_rec.attribute4,
        p_formula_detail_rec.attribute5, p_formula_detail_rec.attribute6,
        p_formula_detail_rec.attribute7, p_formula_detail_rec.attribute8,
        p_formula_detail_rec.attribute9, p_formula_detail_rec.attribute10,
        p_formula_detail_rec.attribute11, p_formula_detail_rec.attribute12,
        p_formula_detail_rec.attribute13, p_formula_detail_rec.attribute14,
        p_formula_detail_rec.attribute15, p_formula_detail_rec.attribute16,
        p_formula_detail_rec.attribute17, p_formula_detail_rec.attribute18,
        p_formula_detail_rec.attribute19, p_formula_detail_rec.attribute20,
        p_formula_detail_rec.attribute21, p_formula_detail_rec.attribute22,
        p_formula_detail_rec.attribute23, p_formula_detail_rec.attribute24,
        p_formula_detail_rec.attribute25, p_formula_detail_rec.attribute26,
        p_formula_detail_rec.attribute27, p_formula_detail_rec.attribute28,
        p_formula_detail_rec.attribute29, p_formula_detail_rec.attribute30,
        p_formula_detail_rec.attribute_category,
        p_formula_detail_rec.prod_percent);
     /* END API Body */
     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula detail Pvt - After insert formulaline insert ');
     END IF;

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula detail Pvt - About to recalculate TOQ ');
     END IF;
     /* Recalculate the TOQ and TIQ */
     GMD_COMMON_VAL.calculate_total_qty(
                  formula_id       => p_formula_detail_rec.formula_id,
                  x_product_qty    => l_product_qty ,
                  x_ingredient_qty => l_ing_qty ,
                  x_uom            => l_uom ,
                  x_return_status  => x_return_status ,
                  x_msg_count      => X_msg_cnt ,
                  x_msg_data       => x_msg_dat );

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula detail Pvt - Update header with TOQ '
                  ||' TIQ = '
                  ||l_ing_qty
                  ||' TOQ =  '
                  ||l_product_qty);
     END IF;
     /* Update formula header table with TOQ and TIQ */
     UPDATE fm_form_mst_b
        SET total_output_qty = l_product_qty,
            total_input_qty  = l_ing_qty,
            yield_uom        = l_uom
      WHERE formula_id       = p_formula_detail_rec.formula_id;

     /* Check if p_commit is set to TRUE */
     IF FND_API.To_Boolean(p_commit) THEN
        Commit;
     END IF;

     /* Get the message count and information */
     FND_MSG_PUB.Count_And_Get (
                 p_count => x_msg_count,
                 p_data  => x_msg_data );
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK to Insert_FormulaDetail_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
                  p_count => x_msg_count,
                  p_data  => x_msg_data   );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK to Insert_FormulaDetail_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                   p_count => x_msg_count,
                   p_data  => x_msg_data   );

     WHEN OTHERS THEN
       ROLLBACK to Insert_FormulaDetail_PVT;
       fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail Pvt - In OTHERS Exception Section  '
                   ||' - '
                   ||x_return_status);
       END IF;

  END Insert_FormulaDetail;

  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Update_FormulaDetail                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for updating a formula.           */
  /*   details.                                                               */
  /* HISTORY:                                                                 */
  /*    Kapil ME Bug# 5716318 - Added the new Percentage Fields for Auto -Prod*/
  /*                            ME.                                           */
  /* ======================================================================== */
  PROCEDURE Update_FormulaDetail
  (  p_api_version            IN           NUMBER
     ,p_init_msg_list         IN           VARCHAR2
     ,p_commit                IN           VARCHAR2
     ,x_return_status         OUT NOCOPY   VARCHAR2
     ,x_msg_count             OUT NOCOPY   NUMBER
     ,x_msg_data              OUT NOCOPY   VARCHAR2
     ,p_formula_detail_rec    IN           fm_matl_dtl%ROWTYPE
  )
  IS

     /*  Local Variables definitions */
     l_api_name              CONSTANT    VARCHAR2(30)  := 'UPDATE_FORMULADETAIL';
     l_api_version           CONSTANT    NUMBER        := 1.0;
     l_line_no                           fm_matl_dtl.line_no%TYPE;
     l_line_type                         fm_matl_dtl.line_type%TYPE;
     l_qty                               fm_matl_dtl.qty%TYPE;
     l_item_um                           fm_matl_dtl.detail_uom%TYPE;
     l_release_type                      fm_matl_dtl.release_type%TYPE;
     l_scrap_factor                      fm_matl_dtl.scrap_factor%TYPE;
     l_scale_type                        fm_matl_dtl.scale_type%TYPE;
     l_phantom_type                      fm_matl_dtl.phantom_type%TYPE;
     X_msg_cnt                           NUMBER;
     X_msg_dat                           VARCHAR2(100);
     X_status                            VARCHAR2(1);
     l_product_qty                       NUMBER;
     l_ing_qty                           NUMBER;
     l_uom                               VARCHAR2(3);
     l_return_val                        NUMBER := 0;

     CURSOR C_get_orgid (V_formula_id NUMBER) IS
       SELECT owner_organization_id
       FROM   fm_form_mst_b
       WHERE  formula_id = V_formula_id;
    l_org_id	NUMBER;

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Update_FormulaDetail_PVT;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call  ( l_api_version
                                           ,p_api_version
                                           ,l_api_name
                                           ,G_PKG_NAME  )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*  Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;
     /*  Initialize API return status to success */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (p_formula_detail_rec.organization_id IS NULL) THEN
       OPEN C_get_orgid (p_formula_detail_rec.formula_id);
       FETCH C_get_orgid INTO l_org_id;
       CLOSE C_get_orgid;
     ELSE
       l_org_id := p_formula_detail_rec.organization_id;
     END IF;

     /*  API body */
     /*  Later on to be changed to update a business view */
     /*  and not a table. */
     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In Formula Detail PVT - '
                      ||' Before the update of fm_matl_dtl   '
                      ||' formulaline id - '
                      ||p_formula_detail_rec.formulaline_id
                      ||' line no '
                      ||p_formula_detail_rec.line_no
                      ||' line_type '
                      ||p_formula_detail_rec.line_type
                      ||' Contrib in d '
                      ||p_formula_detail_rec.contribute_yield_ind
                      ||' - '
                      ||x_return_status);
     END IF;
     UPDATE fm_matl_dtl SET
        line_no                  = p_formula_detail_rec.line_no,
        line_type                = p_formula_detail_rec.line_type,
        qty                      = p_formula_detail_rec.qty,
	organization_id          = l_org_id,
	revision	         = p_formula_detail_rec.revision,
        detail_uom               = p_formula_detail_rec.detail_uom,
        release_type             = p_formula_detail_rec.release_type,
        scale_type               = p_formula_detail_rec.scale_type,
        scrap_factor             = p_formula_detail_rec.scrap_factor,
        cost_alloc               = p_formula_detail_rec.cost_alloc,
        phantom_type             = p_formula_detail_rec.phantom_type,
        buffer_ind               = p_formula_detail_rec.buffer_ind,
        rework_type              = p_formula_detail_rec.rework_type,
        tpformula_id             = p_formula_detail_rec.tpformula_id    ,
        iaformula_id             = p_formula_detail_rec.iaformula_id    ,
        scale_multiple           = p_formula_detail_rec.scale_multiple  ,
        contribute_yield_ind     = p_formula_detail_rec.contribute_yield_ind ,
        scale_uom                = p_formula_detail_rec.scale_uom ,
        contribute_step_qty_ind  = p_formula_detail_rec.contribute_step_qty_ind,
        scale_rounding_variance  = p_formula_detail_rec.scale_rounding_variance,
        rounding_direction       = p_formula_detail_rec.rounding_direction,
        /*Bug 2509076 - Thomas Daniel  QM Integration */
        by_product_type          = p_formula_detail_rec.by_product_type,
        ingredient_end_date      = p_formula_detail_rec.ingredient_end_date, --bug 4479101
        text_code                = p_formula_detail_rec.text_code,
        last_update_date         = p_formula_detail_rec.last_update_date,
        last_updated_by          = p_formula_detail_rec.last_updated_by,
        last_update_login        = p_formula_detail_rec.last_update_login,
        attribute1               = p_formula_detail_rec.attribute1,
        attribute2               = p_formula_detail_rec.attribute2,
        attribute3               = p_formula_detail_rec.attribute3,
        attribute4               = p_formula_detail_rec.attribute4,
        attribute5               = p_formula_detail_rec.attribute5,
        attribute6               = p_formula_detail_rec.attribute6,
        attribute7               = p_formula_detail_rec.attribute7,
        attribute8               = p_formula_detail_rec.attribute8,
        attribute9               = p_formula_detail_rec.attribute9,
        attribute10              = p_formula_detail_rec.attribute10,
        attribute11              = p_formula_detail_rec.attribute11,
        attribute12              = p_formula_detail_rec.attribute12,
        attribute13              = p_formula_detail_rec.attribute13,
        attribute14              = p_formula_detail_rec.attribute14,
        attribute15              = p_formula_detail_rec.attribute15,
        attribute16              = p_formula_detail_rec.attribute16,
        attribute17              = p_formula_detail_rec.attribute17,
        attribute18              = p_formula_detail_rec.attribute18,
        attribute19              = p_formula_detail_rec.attribute19,
        attribute20              = p_formula_detail_rec.attribute20,
        attribute21              = p_formula_detail_rec.attribute21,
        attribute22              = p_formula_detail_rec.attribute22,
        attribute23              = p_formula_detail_rec.attribute23,
        attribute24              = p_formula_detail_rec.attribute24,
        attribute25              = p_formula_detail_rec.attribute25,
        attribute26              = p_formula_detail_rec.attribute26,
        attribute27              = p_formula_detail_rec.attribute27,
        attribute28              = p_formula_detail_rec.attribute28,
        attribute29              = p_formula_detail_rec.attribute29,
        attribute30              = p_formula_detail_rec.attribute30,
        attribute_category       = p_formula_detail_rec.attribute_category,
        prod_percent             = p_formula_detail_rec.prod_percent
     WHERE
        formulaline_id = p_formula_detail_rec.formulaline_id;

     /* End API body */
     /* Calculate the total input and output qty and update the formula header table */
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In Formula Detail PVT - '
                      ||' Before the TOQ calculation   '
                                 ||' - '
                                 ||x_return_status);
     END IF;
     GMD_COMMON_VAL.calculate_total_qty(
                    FORMULA_ID       => p_formula_detail_rec.formula_id,
                    X_PRODUCT_QTY    => l_product_qty ,
                    X_INGREDIENT_QTY => l_ing_qty ,
                    X_UOM            => l_uom ,
                    X_RETURN_STATUS  => x_return_status ,
                    X_MSG_COUNT      => X_msg_cnt ,
                    X_MSG_DATA       => x_msg_dat );

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In Formula Detail PVT - '
                      ||' Before the update of fm header with toq and tiq =   '
                             ||' TOQ = '
                             ||l_product_qty
                             ||' TIQ = '
                             ||l_ing_qty
                             ||' - '
                             ||x_return_status);
     END IF;
     UPDATE  fm_form_mst_b
     SET     total_output_qty = l_product_qty,
             total_input_qty = l_ing_qty,
             yield_uom = l_uom
     WHERE   formula_id = p_formula_detail_rec.formula_id;


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
          ROLLBACK to Update_FormulaDetail_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK to Update_FormulaDetail_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

     WHEN OTHERS THEN
          ROLLBACK to Update_FormulaDetail_PVT;
          fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Detail Pvt - In OTHERS Exception Section  '
                ||' - '
                ||x_return_status);
       END IF;
  END Update_FormulaDetail;

  /* ============================================= */
  /* Procedure:                                    */
  /*   Delete_FormulaDetail                        */
  /*                                               */
  /* DESCRIPTION:                                  */
  /*   This PL/SQL procedure is responsible for    */
  /*   deleting formula detail.                    */
  /* HISTORY:                                      */
  /* ============================================= */
     PROCEDURE Delete_FormulaDetail
     (  p_api_version           IN      NUMBER                                  ,
        p_init_msg_list         IN      VARCHAR2                                ,
        p_commit                IN      VARCHAR2                                ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        x_msg_count             OUT NOCOPY      NUMBER                                  ,
        x_msg_data              OUT NOCOPY      VARCHAR2                                ,
        p_formula_detail_rec    IN      fm_matl_dtl%ROWTYPE
     )
     IS

        /*  Local Variables definitions */
        l_api_name              CONSTANT    VARCHAR2(30)  := 'DELETE_FORMULADETAIL';
        l_api_version           CONSTANT    NUMBER        := 1.0;

        X_msg_cnt       NUMBER;
        X_msg_dat       VARCHAR2(100);
        X_status varchar2(1);
        l_product_qty NUMBER;
        l_ing_qty       NUMBER;
        l_uom   mtl_units_of_measure.unit_of_measure%TYPE;

     BEGIN
        /*  Define Savepoint */
        SAVEPOINT  Delete_FormulaDetail_PVT;

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

                DELETE FROM fm_matl_dtl
                WHERE
                formulaline_id = p_formula_detail_rec.formulaline_id;

                IF(SQL%ROWCOUNT = 0) THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                /* End API body */

                /* Calculate the total input and output qty and update the formula header table */
        GMD_COMMON_VAL.calculate_total_qty(
                        FORMULA_ID           => p_formula_detail_rec.formula_id,
                        X_PRODUCT_QTY        => l_product_qty ,
                        X_INGREDIENT_QTY     => l_ing_qty ,
                        X_UOM                => l_uom ,
                        X_RETURN_STATUS      => x_return_status ,
                        X_MSG_COUNT          => X_msg_cnt ,
                        X_MSG_DATA           => x_msg_dat );


        update  fm_form_mst_b
                set             total_output_qty = l_product_qty,
                                total_input_qty = l_ing_qty,
                                yield_uom = l_uom
                where   formula_id = p_formula_detail_rec.formula_id;

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
                ROLLBACK to Delete_FormulaDetail_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK to Delete_FormulaDetail_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get (
                                p_count => x_msg_count,
                                p_data  => x_msg_data   );

        WHEN OTHERS THEN
                ROLLBACK to Delete_FormulaDetail_PVT;
                fnd_msg_pub.add_exc_msg (G_pkg_name, l_api_name);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Delete_FormulaDetail;

END GMD_FORMULA_DETAIL_PVT;

/
