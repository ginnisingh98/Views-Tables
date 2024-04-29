--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_HEADER_PVT" AS
/* $Header: GMDVFMHB.pls 120.3.12010000.2 2009/12/04 09:09:58 kannavar ship $ */

  G_PKG_NAME CONSTANT  VARCHAR2(30)    := 'GMD_FORMULA_HEADER_PVT';

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
  /*   This PL/SQL procedure is responsible for inserting a formula.          */
  /* ======================================================================== */
  PROCEDURE Insert_FormulaHeader
  (  p_api_version        IN         NUMBER
    ,p_init_msg_list      IN         VARCHAR2
    ,p_commit             IN         VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_formula_header_rec IN         FM_FORM_MST%ROWTYPE
  )
  IS
     /*  Local Variables definitions */
     l_api_name     CONSTANT    VARCHAR2(30)  := 'INSERT_FORMULAHEADER';
     l_api_version  CONSTANT    NUMBER        := 1.0;

     formula_rowid  VARCHAR2(32);
     v_count        NUMBER;
     X_msg_cnt      NUMBER;
     X_msg_dat      VARCHAR2(100);
     X_status       VARCHAR2(1);
     l_product_qty  NUMBER;
     l_ing_qty      NUMBER;
     l_uom          VARCHAR2(4);

     /* Bug No.9077438 - Start */
  Cursor Cur_fm_sec(vOrgn_id NUMBER) IS
    select user_ind, responsibility_ind
      from gmd_security_control
     where organization_id = vOrgn_id
       and object_type = 'F';

  Cursor Cur_user_access(vOrgn_id NUMBER) IS
    select 1, other_organization_id
      from gmd_security_profiles
     where organization_id = vOrgn_id
       and assign_method_ind = 'M'
       and access_type_ind = 'U'
       and user_id = fnd_global.user_id;

  Cursor Cur_resp_access(vOrgn_id NUMBER) IS
    select 1, other_organization_id
      from gmd_security_profiles
     where organization_id = vOrgn_id
       and assign_method_ind = 'M'
       and access_type_ind = 'U'
       and responsibility_id = fnd_global.resp_id;

  l_user_ind      VARCHAR2(1) := 'N';
  l_resp_ind      VARCHAR2(1) := 'N';
  l_sec_cnt       NUMBER(2) := -1;
  l_other_orgn_id NUMBER(5);
  /* Bug No.9077438 - End */

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Insert_FormulaHeader_PVT;

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

     /* Insert calls the mls package */
     /* New changes to include MLS */
     /* This package inserts into the <entity_b> and <entity_tl> table. */
     /* <entity_vl> is a view of the <_b> and <_tl> table. */
     /* currently we have no relationship between the  */
     /* fm_form_mst and vl table.  However at a later time fm_form_mst will */
     /* be a compatible synonym of this view. */

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('    ');
       END IF;

       /* Bug No.9077438 - Start */
begin

  OPEN Cur_fm_sec(p_formula_header_rec.owner_organization_id);
  FETCH Cur_fm_sec
    INTO l_user_ind, l_resp_ind;
  IF (Cur_fm_sec%FOUND) THEN
    IF l_user_ind = 'Y' THEN
      l_sec_cnt       := -1;
      l_other_orgn_id := NULL;
      OPEN Cur_user_access(p_formula_header_rec.owner_organization_id);
      FETCH Cur_user_access
        INTO l_sec_cnt, l_other_orgn_id;
      IF (Cur_user_access%FOUND) THEN
        IF l_sec_cnt = 1 THEN
          INSERT INTO GMD_FORMULA_SECURITY
            (formula_security_id,
             formula_id,
             access_type_ind,
             organization_id,
             user_id,
             responsibility_id,
             other_organization_id,
             created_by,
             creation_date,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (gmd_formula_security_id_s.NEXTVAL,
             p_formula_header_rec.formula_id,
             'U',
             p_formula_header_rec.owner_organization_id,
             p_formula_header_rec.created_by,
             NULL,
             l_other_orgn_id,
             p_formula_header_rec.created_by,
             SYSDATE,
             SYSDATE,
             p_formula_header_rec.created_by,
             p_formula_header_rec.last_update_login);

         END IF; --IF l_sec_cnt = 1 THEN
      END IF; --IF (Cur_user_access%FOUND) THEN
      CLOSE Cur_user_access;
    END IF; --IF l_user_ind = 'Y' THEN
    IF l_resp_ind = 'Y' THEN
      l_sec_cnt       := -1;
      l_other_orgn_id := NULL;
      OPEN Cur_resp_access(p_formula_header_rec.owner_organization_id);
      FETCH Cur_resp_access
        INTO l_sec_cnt, l_other_orgn_id;
      IF (Cur_resp_access%FOUND) THEN
        IF l_sec_cnt = 1 THEN
          INSERT INTO GMD_FORMULA_SECURITY
            (formula_security_id,
             formula_id,
             access_type_ind,
             organization_id,
             user_id,
             responsibility_id,
             other_organization_id,
             created_by,
             creation_date,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (gmd_formula_security_id_s.NEXTVAL,
             p_formula_header_rec.formula_id,
             'U',
             p_formula_header_rec.owner_organization_id,
             NULL,
             fnd_global.resp_id,
             l_other_orgn_id,
             p_formula_header_rec.created_by,
             SYSDATE,
             SYSDATE,
             p_formula_header_rec.created_by,
             p_formula_header_rec.last_update_login);

        END IF; --IF l_sec_cnt = 1 THEN
      END IF; --IF (Cur_resp_access%FOUND) THEN
      CLOSE Cur_resp_access;
    END IF; --IF l_resp_ind = 'Y' THEN
  END IF; --IF (Cur_fm_sec%FOUND) THEN
CLOSE Cur_fm_sec;
EXCEPTION
  WHEN others then
    ROLLBACK to Insert_FormulaHeader_PVT;
    fnd_msg_pub.add_exc_msg('GMD_FORMULA_HEADER_PVT',
                            'Insert_Formula_Header');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line(' In Formula Header Pvt - Formula Security OTHERS Exception ' ||
                         ' - ' || x_return_status);
    END IF;
end;

IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula header Pvt - Formula Security End');
     END IF;
/* Bug No.9077438 - End */

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula header Pvt - About to insert fm id = '
                  ||p_formula_header_rec.formula_id);
     END IF;

     FM_FORM_MST_MLS.INSERT_ROW(
         X_ROWID                   => formula_rowid,
         X_FORMULA_ID              => p_formula_header_rec.formula_id,
         X_MASTER_FORMULA_ID       => p_formula_header_rec.master_formula_id,
         X_OWNER_ORGANIZATION_ID   => p_formula_header_rec.owner_organization_id,
         X_TOTAL_INPUT_QTY         => p_formula_header_rec.total_input_qty,
         X_TOTAL_OUTPUT_QTY        => p_formula_header_rec.total_output_qty,
         X_YIELD_UOM               => p_formula_header_rec.yield_uom,
         X_FORMULA_STATUS          => p_formula_header_rec.formula_status,
         X_OWNER_ID                => p_formula_header_rec.owner_id,
         X_PROJECT_ID              => NULL,
         X_TEXT_CODE               => p_formula_header_rec.text_code,
         X_DELETE_MARK             => p_formula_header_rec.delete_mark,
         X_FORMULA_NO              => p_formula_header_rec.formula_no,
         X_FORMULA_VERS            => p_formula_header_rec.formula_vers,
         X_FORMULA_TYPE            => p_formula_header_rec.formula_type,
         X_IN_USE                  => p_formula_header_rec.in_use,
         X_INACTIVE_IND            => p_formula_header_rec.inactive_ind,
         X_SCALE_TYPE              => p_formula_header_rec.scale_type,
         X_FORMULA_CLASS           => p_formula_header_rec.formula_class,
         X_FMCONTROL_CLASS         => p_formula_header_rec.fmcontrol_class,
         X_ATTRIBUTE_CATEGORY      => p_formula_header_rec.attribute_category,
         X_ATTRIBUTE1              => p_formula_header_rec.attribute1,
         X_ATTRIBUTE2              => p_formula_header_rec.attribute2,
         X_ATTRIBUTE3              => p_formula_header_rec.attribute3,
         X_ATTRIBUTE4              => p_formula_header_rec.attribute4,
         X_ATTRIBUTE5              => p_formula_header_rec.attribute5,
         X_ATTRIBUTE6              => p_formula_header_rec.attribute6,
         X_ATTRIBUTE7              => p_formula_header_rec.attribute7,
         X_ATTRIBUTE8              => p_formula_header_rec.attribute8,
         X_ATTRIBUTE9              => p_formula_header_rec.attribute9,
         X_ATTRIBUTE10             => p_formula_header_rec.attribute10,
         X_ATTRIBUTE11             => p_formula_header_rec.attribute11,
         X_ATTRIBUTE12             => p_formula_header_rec.attribute12,
         X_ATTRIBUTE13             => p_formula_header_rec.attribute13,
         X_ATTRIBUTE14             => p_formula_header_rec.attribute14,
         X_ATTRIBUTE15             => p_formula_header_rec.attribute15,
         X_ATTRIBUTE16             => p_formula_header_rec.attribute16,
         X_ATTRIBUTE17             => p_formula_header_rec.attribute17,
         X_ATTRIBUTE18             => p_formula_header_rec.attribute18,
         X_ATTRIBUTE19             => p_formula_header_rec.attribute19,
         X_ATTRIBUTE20             => p_formula_header_rec.attribute20,
         X_ATTRIBUTE21             => p_formula_header_rec.attribute21,
         X_ATTRIBUTE22             => p_formula_header_rec.attribute22,
         X_ATTRIBUTE23             => p_formula_header_rec.attribute23,
         X_ATTRIBUTE24             => p_formula_header_rec.attribute24,
         X_ATTRIBUTE25             => p_formula_header_rec.attribute25,
         X_ATTRIBUTE26             => p_formula_header_rec.attribute26,
         X_ATTRIBUTE27             => p_formula_header_rec.attribute27,
         X_ATTRIBUTE28             => p_formula_header_rec.attribute28,
         X_ATTRIBUTE29             => p_formula_header_rec.attribute29,
         X_ATTRIBUTE30             => p_formula_header_rec.attribute30,
         X_FORMULA_DESC1           => p_formula_header_rec.formula_desc1,
         X_FORMULA_DESC2           => p_formula_header_rec.formula_desc2,
         X_CREATION_DATE           => p_formula_header_rec.creation_date,
         X_CREATED_BY              => p_formula_header_rec.created_by,
         X_LAST_UPDATE_DATE        => p_formula_header_rec.last_update_date,
         X_LAST_UPDATED_BY         => p_formula_header_rec.last_updated_by,
         X_LAST_UPDATE_LOGIN       => p_formula_header_rec.last_update_login,
         -- Bug# 5716318
         X_AUTO_PRODUCT_CALC       => NVL(p_formula_header_rec.auto_product_calc,'N'));
     /* Test if formula_id is returned */
     IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' In formula header Pvt - After fm insert row_id = '
                  ||formula_rowid);
     END IF;

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
       ROLLBACK to Insert_FormulaHeader_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK to Insert_FormulaHeader_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );

     WHEN OTHERS THEN
       ROLLBACK to Insert_FormulaHeader_PVT;
       fnd_msg_pub.add_exc_msg ('GMD_FORMULA_HEADER_PVT', 'Insert_Formula_Header');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
           gmd_debug.put_line(' In Formula Header Pvt - In OTHERS Exception Section  '
                ||' - '
                ||x_return_status);
       END IF;

  END Insert_FormulaHeader;

  /* ======================================================================== */
  /* Procedure:                                                               */
  /*   Update_FormulaHeader                                                   */
  /*                                                                          */
  /* DESCRIPTION:                                                             */
  /*   This PL/SQL procedure is responsible for updating a formula.           */
  /* ======================================================================== */
  PROCEDURE Update_FormulaHeader
  (  p_api_version           IN      NUMBER
     ,p_init_msg_list         IN      VARCHAR2
     ,p_commit                IN      VARCHAR2
     ,x_return_status         OUT NOCOPY     VARCHAR2
     ,x_msg_count             OUT NOCOPY     NUMBER
     ,x_msg_data              OUT NOCOPY     VARCHAR2
     ,p_formula_header_rec    IN      fm_form_mst%ROWTYPE
  )
  IS
     /*  Local Variables definitions */
     l_api_name        CONSTANT    VARCHAR2(30)         := 'UPDATE_FORMULAHEADER';
     l_api_version     CONSTANT    NUMBER               := 1.0;
     l_scale_type      fm_form_mst.scale_type%TYPE;
     l_formula_desc1   fm_form_mst.formula_desc1%TYPE;
     l_return_val      NUMBER := 0 ;

     X_msg_cnt         NUMBER;
     X_msg_dat         VARCHAR2(100);
     X_status          VARCHAR2(1);
     l_product_qty     NUMBER;
     l_ing_qty         NUMBER;
     l_uom             VARCHAR2(4);

  BEGIN
     /*  Define Savepoint */
     SAVEPOINT  Update_FormulaHeader_PVT;

     /*  Standard Check for API compatibility */
     IF NOT FND_API.Compatible_API_Call( l_api_version
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

     /* Call the Update_row procedure for mls */
     /* To modify to call the approp variables */
     IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pvt - Before updating fm_form_mst table '
                              ||p_formula_header_rec.formula_id);
     END IF;
     FM_FORM_MST_MLS.UPDATE_ROW(
       X_FORMULA_ID          => p_formula_header_rec.formula_id,
       X_OWNER_ORGANIZATION_ID => p_formula_header_rec.owner_organization_id,
       X_TEXT_CODE           => p_formula_header_rec.text_code,
       X_DELETE_MARK         => p_formula_header_rec.delete_mark,
       X_TOTAL_INPUT_QTY     => p_formula_header_rec.total_input_qty,
       X_PROJECT_ID          => null,
       X_TOTAL_OUTPUT_QTY    => p_formula_header_rec.total_output_qty,
       X_YIELD_UOM           => p_formula_header_rec.yield_uom,
       X_FORMULA_STATUS      => p_formula_header_rec.formula_status,
       X_OWNER_ID            => p_formula_header_rec.owner_id,
       X_FORMULA_NO          => p_formula_header_rec.formula_no,
       X_FORMULA_VERS        => p_formula_header_rec.formula_vers,
       X_FORMULA_TYPE        => p_formula_header_rec.formula_type,
       X_IN_USE              => p_formula_header_rec.in_use,
       X_INACTIVE_IND        => p_formula_header_rec.inactive_ind,
       X_SCALE_TYPE          => p_formula_header_rec.scale_type,
       X_FORMULA_CLASS       => p_formula_header_rec.formula_class,
       X_FMCONTROL_CLASS     => p_formula_header_rec.fmcontrol_class,
       X_ATTRIBUTE_CATEGORY  => p_formula_header_rec.attribute_category,
       X_ATTRIBUTE1          => p_formula_header_rec.attribute1,
       X_ATTRIBUTE2          => p_formula_header_rec.attribute2,
       X_ATTRIBUTE3          => p_formula_header_rec.attribute3,
       X_ATTRIBUTE4          => p_formula_header_rec.attribute4,
       X_ATTRIBUTE5          => p_formula_header_rec.attribute5,
       X_ATTRIBUTE6          => p_formula_header_rec.attribute6,
       X_ATTRIBUTE7          => p_formula_header_rec.attribute7,
       X_ATTRIBUTE8          => p_formula_header_rec.attribute8,
       X_ATTRIBUTE9          => p_formula_header_rec.attribute9,
       X_ATTRIBUTE10         => p_formula_header_rec.attribute10,
       X_ATTRIBUTE11         => p_formula_header_rec.attribute11,
       X_ATTRIBUTE12         => p_formula_header_rec.attribute12,
       X_ATTRIBUTE13         => p_formula_header_rec.attribute13,
       X_ATTRIBUTE14         => p_formula_header_rec.attribute14,
       X_ATTRIBUTE15         => p_formula_header_rec.attribute15,
       X_ATTRIBUTE16         => p_formula_header_rec.attribute16,
       X_ATTRIBUTE17         => p_formula_header_rec.attribute17,
       X_ATTRIBUTE18         => p_formula_header_rec.attribute18,
       X_ATTRIBUTE19         => p_formula_header_rec.attribute19,
       X_ATTRIBUTE20         => p_formula_header_rec.attribute20,
       X_ATTRIBUTE21         => p_formula_header_rec.attribute21,
       X_ATTRIBUTE22         => p_formula_header_rec.attribute22,
       X_ATTRIBUTE23         => p_formula_header_rec.attribute23,
       X_ATTRIBUTE24         => p_formula_header_rec.attribute24,
       X_ATTRIBUTE25         => p_formula_header_rec.attribute25,
       X_ATTRIBUTE26         => p_formula_header_rec.attribute26,
       X_ATTRIBUTE27         => p_formula_header_rec.attribute27,
       X_ATTRIBUTE28         => p_formula_header_rec.attribute28,
       X_ATTRIBUTE29         => p_formula_header_rec.attribute29,
       X_ATTRIBUTE30         => p_formula_header_rec.attribute30,
       X_FORMULA_DESC1       => p_formula_header_rec.formula_desc1,
       X_FORMULA_DESC2       => p_formula_header_rec.formula_desc2,
       X_LAST_UPDATE_DATE    => p_formula_header_rec.last_update_date,
       X_LAST_UPDATED_BY     => p_formula_header_rec.last_updated_by,
       X_LAST_UPDATE_LOGIN   => p_formula_header_rec.last_update_login,
       -- Bug# 5716318
       X_AUTO_PRODUCT_CALC   => p_formula_header_rec.auto_product_calc);

       /* End API body */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' In Formula Header Pvt - After updating fm_form_mst table ');
       END IF;

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
       ROLLBACK to Update_FormulaHeader_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pvt - In Error Exception Section  '
                   ||' - '
                   ||x_return_status);
       END IF;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK to Update_FormulaHeader_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pvt - In Unexpected Exception Section  '
                   ||' - '
                   ||x_return_status);
       END IF;

     WHEN OTHERS THEN
       ROLLBACK to Update_FormulaHeader_PVT;
       fnd_msg_pub.add_exc_msg ('GMD_FORMULA_HEADER_PVT', 'Update_Formula_Header');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
                       p_count => x_msg_count,
                       p_data  => x_msg_data   );
       IF (l_debug = 'Y') THEN
            gmd_debug.put_line(' In Formula Header Pvt - In Others Exception Section  '
                   ||' - '
                   ||x_return_status);
       END IF;

  END Update_FormulaHeader;

END GMD_FORMULA_HEADER_PVT;

/
