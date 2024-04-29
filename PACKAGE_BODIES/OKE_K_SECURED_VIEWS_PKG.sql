--------------------------------------------------------
--  DDL for Package Body OKE_K_SECURED_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_SECURED_VIEWS_PKG" AS
/* $Header: OKEKSVB.pls 120.2.12000000.2 2007/02/12 11:47:47 nnadahal ship $ */

--
--  Private functions and procedures
--
PROCEDURE Print_Text_Buffer
( X_Target                IN     NUMBER
, X_Text_Buffer           IN     VARCHAR2
, X_Wrap_Text             IN     BOOLEAN
) IS

i           NUMBER;
j           NUMBER;
LineWidth   NUMBER := 77;

BEGIN

  FND_FILE.NEW_LINE( X_Target , 1 );

  IF ( X_Wrap_Text ) THEN
    i := 1;
    j := LENGTH( X_Text_Buffer );

    LOOP
      FND_FILE.PUT_LINE( X_Target
                       , SUBSTR( X_Text_Buffer , i , LineWidth ) );
      i := i + LineWidth;
      EXIT WHEN i >= j;
    END LOOP;
  ELSE
    FND_FILE.PUT_LINE( X_Target , X_Text_Buffer );
  END IF;

  FND_FILE.NEW_LINE( X_Target , 1 );

END;


PROCEDURE Generate_Secured_View
( X_Object_Name           IN     VARCHAR2
, X_Header_ID_Col         IN     VARCHAR2
, X_Create_History_View   IN     BOOLEAN
, X_Error_Buf             IN OUT NOCOPY VARCHAR2
) IS

RCSHeader           VARCHAR2(240) := '$Header: OKEKSVB.pls 120.2.12000000.2 2007/02/12 11:47:47 nnadahal ship $';
ColumnList          VARCHAR2(10000);
SelectList          VARCHAR2(30000);
DecodePair          VARCHAR2(10000);
SecuredValue        VARCHAR2(80);
ViewSyntax          VARCHAR2(32500);
UnsecViewName       VARCHAR2(30);
SecViewName         VARCHAR2(30);
ApplsysSchema       VARCHAR2(30);

CURSOR ObjAttr
( C_Object_Name     VARCHAR2
)  IS
  SELECT oa.attribute_code
  ,      oa.datatype
  ,      oap.securable_flag
  FROM   oke_object_attributes_b oa
  ,      oke_object_attributes_b oap
  WHERE  oa.database_object_name = C_Object_Name
  AND    oap.database_object_name = oa.database_object_name
  AND    oa.view_column_flag = 'Y'
  AND    oap.attribute_code = nvl( oa.parent_attribute_code
                                 , oa.attribute_code )
  ORDER BY oa.attribute_code;

CURSOR SecRole
( C_Object_Name     VARCHAR2
, C_Attribute_Code  VARCHAR2
) IS
  SELECT Role_ID
  FROM   oke_compiled_access_rules
  WHERE  secured_object_name = C_Object_Name
  AND    attribute_code = C_attribute_code
  AND    access_level = OKE_K_SECURITY_PKG.G_NO_ACCESS
  ORDER BY Role_ID;

BEGIN

  SELECT MIN(ou.Oracle_Username)
  INTO   ApplsysSchema
  FROM   fnd_product_installations pi
  ,      fnd_oracle_userid ou
  WHERE  ou.Oracle_ID = pi.Oracle_ID
  AND    Application_ID = 0;

  ColumnList := 'ROW_ID , CREATION_DATE , CREATED_BY , LAST_UPDATE_DATE , ' ||
                'LAST_UPDATED_BY , LAST_UPDATE_LOGIN , ATTRIBUTE_CATEGORY , ' ||
                'ATTRIBUTE1 , ATTRIBUTE2 , ATTRIBUTE3 , ' ||
                'ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6 , ' ||
                'ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 , ' ||
                'ATTRIBUTE10 , ATTRIBUTE11 , ATTRIBUTE12 , ' ||
                'ATTRIBUTE13 , ATTRIBUTE14 , ATTRIBUTE15 , ' ||
                'MAJOR_VERSION , MINOR_VERSION , VERSION_DISP ';
  SelectList := 'K.ROW_ID , K.CREATION_DATE , K.CREATED_BY , K.LAST_UPDATE_DATE , ' ||
                'K.LAST_UPDATED_BY , K.LAST_UPDATE_LOGIN , K.ATTRIBUTE_CATEGORY , ' ||
                'K.ATTRIBUTE1 , K.ATTRIBUTE2 , K.ATTRIBUTE3 , ' ||
                'K.ATTRIBUTE4 , K.ATTRIBUTE5 , K.ATTRIBUTE6 , ' ||
                'K.ATTRIBUTE7 , K.ATTRIBUTE8 , K.ATTRIBUTE9 , ' ||
                'K.ATTRIBUTE10 , K.ATTRIBUTE11 , K.ATTRIBUTE12 , ' ||
                'K.ATTRIBUTE13 , K.ATTRIBUTE14 , K.ATTRIBUTE15 , ' ||
                'K.MAJOR_VERSION , K.MINOR_VERSION , K.VERSION_DISP ';

  FOR ObjAttrRec IN ObjAttr( X_Object_Name ) LOOP

    ColumnList := ColumnList || ' , ' || ObjAttrRec.Attribute_Code;

    IF ( ObjAttrRec.Securable_Flag = 'N' ) THEN

      SelectList := SelectList || ' , K.' || ObjAttrRec.Attribute_Code;

    ELSE

      IF ( ObjAttrRec.DataType = 'NUMBER' ) THEN
        SecuredValue := 'TO_NUMBER(NULL)';
      ELSIF ( ObjAttrRec.DataType = 'DATE' ) THEN
        SecuredValue := 'TO_DATE(NULL)';
      ELSE
        SecuredValue := 'NULL';
      END IF;

      DecodePair := NULL;

      FOR SecRoleRec IN SecRole( X_Object_Name
                               , ObjAttrRec.Attribute_Code ) LOOP

        DecodePair := DecodePair || TO_CHAR(SecRoleRec.Role_ID) ||
                      ' , ' || SecuredValue || ' , ';

      END LOOP;

      IF ( DecodePair IS NOT NULL ) THEN

       SelectList := SelectList ||
           ' , DECODE( OKE_K_SECURITY_PKG.GET_K_ROLE( K.' || X_Header_ID_Col ||
           ' ) , ' || DecodePair || 'K.' || ObjAttrRec.Attribute_Code || ' ) ';

      ELSE

       SelectList := SelectList || ' , K.' || ObjAttrRec.Attribute_Code;

      END IF;

    END IF;

  END LOOP;

  UnsecViewName  := X_Object_Name || '_FULL_V';
  SecViewName    := X_Object_Name || '_SECURE_V';

  ViewSyntax :=
    'CREATE OR REPLACE FORCE VIEW ' || SecViewName || ' ( ' ||
    ColumnList || ' ) AS SELECT /* ' || RCSHeader || ' */ ' || SelectList ||
    ' FROM ' || UnsecViewName || ' K ,' ||
    ' ( SELECT ID K_HDR_ID ,' ||
    ' OKE_K_SECURITY_PKG.GET_K_ACCESS( ID ) K_ACCESS ' ||
    ' FROM OKC_K_HEADERS_B ) ACC' ||
    ' WHERE ACC.K_HDR_ID = K.' || X_Header_ID_Col ||
    ' AND ACC.K_ACCESS IN ( ''EDIT'' , ''VIEW'' )' ;

-- ||
--    ' AND ( OKE_UTILS.CROSS_ORG_ACCESS = ''Y''' ||
--    ' OR NVL(K.AUTHORING_ORG_ID , -99) = OKE_UTILS.ORG_ID )';

  Print_Text_Buffer( FND_FILE.OUTPUT , ViewSyntax , TRUE );

  AD_DDL.DO_DDL( ApplsysSchema
               , 'OKE'
               , AD_DDL.CREATE_VIEW
               , ViewSyntax
               , SecViewName
               );

  FND_MESSAGE.SET_NAME('OKE' , 'OKE_SEC_GEN_VIEW_SUCC');
  FND_MESSAGE.SET_TOKEN('VIEW' , SecViewName);
  Print_Text_Buffer( FND_FILE.LOG , FND_MESSAGE.GET , FALSE );

  IF ( X_Create_History_View ) THEN

    UnsecViewName := X_Object_Name || '_FULL_HV';
    SecViewName   := X_Object_Name || '_SECURE_HV';

    ViewSyntax :=
      'CREATE OR REPLACE FORCE VIEW ' || SecViewName || ' ( ' ||
       ColumnList || ' ) AS SELECT /* ' || RCSHeader || ' */ ' || SelectList ||
      ' FROM ' || UnsecViewName || ' K ,' ||
      ' ( SELECT ID K_HDR_ID ,' ||
      ' OKE_K_SECURITY_PKG.GET_K_ACCESS( ID ) K_ACCESS ' ||
      ' FROM OKC_K_HEADERS_B ) ACC' ||
      ' WHERE ACC.K_HDR_ID = K.' || X_Header_ID_Col ||
      ' AND ACC.K_ACCESS IN ( ''EDIT'' , ''VIEW'' )';

-- ||
--      ' AND ( OKE_UTILS.CROSS_ORG_ACCESS = ''Y''' ||
--      ' OR NVL(K.AUTHORING_ORG_ID , -99) = OKE_UTILS.ORG_ID )';

    Print_Text_Buffer( FND_FILE.OUTPUT , ViewSyntax , TRUE );

    AD_DDL.DO_DDL( ApplsysSchema
                 , 'OKE'
                 , AD_DDL.CREATE_VIEW
                 , ViewSyntax
                 , SecViewName
                 );

    FND_MESSAGE.SET_NAME('OKE' , 'OKE_SEC_GEN_VIEW_SUCC');
    FND_MESSAGE.SET_TOKEN('VIEW' , SecViewName);
    Print_Text_Buffer( FND_FILE.LOG , FND_MESSAGE.GET , FALSE );

  END IF;

EXCEPTION
WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKE' , 'OKE_SEC_GEN_VIEW_FAILED');
  FND_MESSAGE.SET_TOKEN('VIEW' , SecViewName);
  Print_Text_Buffer( FND_FILE.LOG , FND_MESSAGE.GET , FALSE );
  Print_Text_Buffer( FND_FILE.LOG , sqlerrm , TRUE );
  IF ( AD_DDL.ERROR_BUF IS NOT NULL ) THEN
    X_Error_Buf := AD_DDL.Error_Buf;
    Print_Text_Buffer( FND_FILE.LOG , AD_DDL.Error_Buf , TRUE );
  ELSE
    X_Error_Buf := sqlerrm;
  END IF;
  RAISE;

END Generate_Secured_View;


--
-- Public Procedures
--
PROCEDURE Generate_Secured_Views
( ERRBUF                           OUT NOCOPY    VARCHAR2
, RETCODE                          OUT NOCOPY    NUMBER
) IS

L_Error_Buf  VARCHAR2(4000);

BEGIN

  Generate_Secured_View ( 'OKE_K_HEADERS'
                        , 'K_HEADER_ID'
                        , TRUE
                        , L_Error_Buf );
  Generate_Secured_View ( 'OKE_K_LINES'
                        , 'HEADER_ID'
                        , TRUE
                        , L_Error_Buf );

  RETCODE := 0;

EXCEPTION
WHEN OTHERS THEN
  ERRBUF := L_Error_Buf;
  RETCODE := 2;

END Generate_Secured_Views;

END OKE_K_SECURED_VIEWS_PKG;

/
