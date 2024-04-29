--------------------------------------------------------
--  DDL for Package Body QPR_DASHBOARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DASHBOARD_UTIL" AS
/* $Header: QPRPDSBB.pls 120.0 2007/10/11 13:11:39 agbennet noship $ */
G_PKG_NAME             CONSTANT   VARCHAR2(30)  := 'QPR_DASHBOARD_UTIL';



PROCEDURE Create_Dashboard_Default
(   p_user_id    IN  NUMBER
   ,p_plan_id    IN  NUMBER

   ,x_return_status   OUT NOCOPY  VARCHAR2
)
IS

l_api_name      CONSTANT   VARCHAR2(30)  :=  'Populate_Dashboard_Util';
l_return_status            VARCHAR2(1)   :=  FND_API.G_RET_STS_SUCCESS;
l_dashboard_type           VARCHAR2(1);
l_source_template_id       NUMBER;
l_dashboard_id             NUMBER;
n_dashboard_id            NUMBER;
l_source_lang              VARCHAR2(4);
l_dashboard_name           VARCHAR2(50);
l_dsb_table   DashboardDetailsTab ;
l_dummy_counter           NUMBER;

TEMPLATE_NOT_FOUND      EXCEPTION;

CURSOR c_dashboard is
       SELECT dashboard_id,source_template_id
       FROM QPR_DASHBOARD_MASTER_B
       WHERE user_id is  null
             and plan_id is  null
             and default_flag = 'Y'
             and dashboard_type = 'T';

BEGIN

  SAVEPOINT  Create_Dashboard_Default_P;
  BEGIN
    SELECT  dashboard_type
    INTO  l_dashboard_type
    FROM QPR_DASHBOARD_MASTER_B
    WHERE user_id = p_user_id
       and plan_id = p_plan_id
       and default_flag = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_dummy_counter := 1;
  END;

  IF SQL%FOUND THEN
      IF l_dashboard_type = 'I' THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         --ask shanmu whether error needs to be raised here
     END IF;
  ELSE
      OPEN c_dashboard;
      LOOP
         FETCH c_dashboard INTO l_dashboard_id,l_source_template_id;

         EXIT when c_dashboard%ROWCOUNT = 1;
         IF c_dashboard%NOTFOUND is null THEN
            raise TEMPLATE_NOT_FOUND;
         END IF;
      END LOOP;


      SELECT QPR_DASHBOARD_MASTER_S.NEXTVAL into n_dashboard_id FROM DUAL;
      Populate_Dashboard_Details(p_user_id,p_plan_id,l_dashboard_id,n_dashboard_id,l_dsb_table,l_return_status);


      IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
           --generate proper error log ask shanmu

          SELECT dashboard_name,source_lang
          INTO l_dashboard_name,l_source_lang
          FROM  QPR_DASHBOARD_MASTER_TL
          WHERE dashboard_id = l_dashboard_id
          and language = (select USERENV('Lang') from dual);


          UPDATE QPR_DASHBOARD_MASTER_B
          SET dashboard_id = n_dashboard_id
               ,user_id = p_user_id
              ,plan_id = p_plan_id
              ,dashboard_type = 'I'
          WHERE dashboard_id = l_dashboard_id;

          UPDATE QPR_DASHBOARD_MASTER_TL
          SET dashboard_id = n_dashboard_id
          WHERE dashboard_id = l_dashboard_id;

          Generate_Default_Rows(l_dashboard_name,l_source_template_id,l_dashboard_id,l_source_lang,l_dsb_table,l_return_status);
      END IF;
  END IF;

  EXCEPTION
     WHEN TEMPLATE_NOT_FOUND THEN
         --populate a msg saying no default template exists in table
         ROLLBACK to Create_Dashboard_Default_P;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('QPR','QPR_API_INVALID_INPUT');
         FND_MESSAGE.SET_TOKEN('ERROR_TEXT','Default  Dashboard template Not found');
         --FND_MESSAGE_PUB.add;
         raise FND_API.G_EXC_ERROR;

     WHEN OTHERS THEN
          ROLLBACK to Create_Dashboard_Default_P;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                 (       G_PKG_NAME,
                         l_api_name
                 );
          END IF;

          raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Dashboard_Default;


-- Procedure POPULATE_DASHBOARD_DETAILS

PROCEDURE Populate_Dashboard_Details
(  p_user_id       IN     NUMBER
  ,p_plan_id       IN     NUMBER
  ,p_dashboard_id  IN     NUMBER
  ,n_dashboard_id  IN     NUMBER
  ,p_dsb_table       OUT  NOCOPY  DashboardDetailsTab
  ,x_return_status   OUT  NOCOPY  VARCHAR2
)
IS

l_api_name      CONSTANT   VARCHAR2(30)  :=  'Populate_Dashboard_Util';
l_return_status            VARCHAR2(1)   :=  FND_API.G_RET_STS_SUCCESS;
l_dashboard_detail_id    NUMBER;
n_dashboard_detail_id   NUMBER;
l_row_number             NUMBER;
l_col_number             NUMBER;
l_content_id             NUMBER;
l_report_type_header_id  NUMBER;
l_report_header_id       NUMBER;
l_counter                INTEGER := 0;


CURSOR c_details (p_dashboard_id IN NUMBER ) IS
   SELECT
dashboard_detail_id,row_number,column_number,content_id,width
   FROM QPR_DASHBOARD_DETAILS
   WHERE dashboard_id = p_dashboard_id;

BEGIN

  SAVEPOINT  Populate_Dashboard_Details_P;
  FOR details_rec in c_details(p_dashboard_id)
  LOOP
    l_dashboard_detail_id := details_rec.dashboard_detail_id;
    l_content_id := details_rec.content_id;
    SELECT report_header_id
    INTO  l_report_header_id
    FROM QPR_REPORT_HDRS_B
    WHERE report_type_header_id = l_content_id
          and user_id = p_user_id
          and plan_id = p_plan_id
          and Seeded_Report_Flag = 'Y';
   SELECT QPR_DASHBOARD_DETAILS_S.NEXTVAL INTO n_dashboard_detail_id FROM DUAL;

   UPDATE QPR_DASHBOARD_DETAILS
   SET DASHBOARD_ID = n_dashboard_id,
   DASHBOARD_DETAIL_ID =  n_dashboard_detail_id,
   CONTENT_ID = l_report_header_id
   WHERE DASHBOARD_DETAIL_ID = l_dashboard_detail_id;

   p_dsb_table(l_counter).dashboard_detail_id := details_rec.dashboard_detail_id;
   p_dsb_table(l_counter).row_number := details_rec.row_number;
   p_dsb_table(l_counter).column_number := details_rec.column_number;
   p_dsb_table(l_counter).content_id := details_rec.content_id;
   p_dsb_table(l_counter).width := details_rec.width;
   l_counter := l_counter + 1;

  END LOOP;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ROLLBACK TO Populate_Dashboard_Details_P;
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
           FND_MESSAGE.Set_Token ('ERROR_TEXT','No Rows for Content Id in Reports table');
           FND_MSG_PUB.Add;
           raise FND_API.G_EXC_ERROR;

      WHEN TOO_MANY_ROWS THEN
           ROLLBACK TO Populate_Dashboard_Details_P;
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
           FND_MESSAGE.Set_Token ('ERROR_TEXT','Too many  Rows for Content Id in Reports table');
           FND_MSG_PUB.Add;
      WHEN OTHERS THEN
           ROLLBACK TO Populate_Dashboard_Details_P;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF   FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
           END IF;

           raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Populate_Dashboard_Details;


-- Procedure Generate_default_Rows

PROCEDURE Generate_Default_Rows
(  p_dashboard_name       IN   VARCHAR2
  ,p_source_template_id   IN NUMBER
  ,p_dashboard_id        IN NUMBER
  ,p_source_lang          IN   VARCHAR2
  ,p_dsb_table            IN   DashboardDetailsTab
  ,x_return_status        OUT  NOCOPY  VARCHAR2
)

IS

l_api_name      CONSTANT   VARCHAR2(30)  :=  'Populate_Dashboard_Util';
l_dashboard_id         NUMBER;
l_dashboard_detail_id  NUMBER;

BEGIN

    SAVEPOINT  Generate_default_Rows_V;
    INSERT INTO QPR_DASHBOARD_MASTER_TL
    (   DASHBOARD_ID
     ,  DASHBOARD_NAME
     ,  LANGUAGE
     ,  SOURCE_LANG
     ,  CREATION_DATE
     ,  CREATED_BY
     ,  LAST_UPDATE_DATE
     ,  LAST_UPDATED_BY
     ,  LAST_UPDATE_LOGIN)
    select
        p_dashboard_id
     ,  p_dashboard_name
     ,  l.language_code
     ,  b.language_code
     ,  sysdate
     ,  fnd_global.user_id()
     ,  sysdate
     ,  fnd_global.user_id()
     ,   0
     FROM fnd_languages l,fnd_languages b
     where l.installed_flag in ('I','B')
     and b.installed_flag = 'B'
     and not exists
         (select null
           from qpr_dashboard_master_tl t
           where t.dashboard_id =  p_dashboard_id
           and t.language = l.language_code);

    INSERT INTO QPR_DASHBOARD_MASTER_B
    (   SOURCE_TEMPLATE_ID
    ,   DASHBOARD_ID
    ,   DASHBOARD_TYPE
    ,   DEFAULT_FLAG
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   LAST_UPDATE_LOGIN
    )
    VALUES
    (   p_source_template_id
    ,   p_dashboard_id
    ,   'T'
    ,   'Y'
    ,   sysdate
    ,   fnd_global.user_id
    ,   sysdate
    ,   fnd_global.user_id
    ,   fnd_global.login_id
    );

   FOR i in 0..(p_dsb_table.count - 1)
   LOOP
      SELECT QPR_DASHBOARD_DETAILS_S.NEXTVAL INTO l_dashboard_detail_id FROM
DUAL;
      INSERT INTO QPR_DASHBOARD_DETAILS
      (  DASHBOARD_DETAIL_ID
      ,  DASHBOARD_ID
      ,  ROW_NUMBER
      ,  COLUMN_NUMBER
      ,  CONTENT_ID
      ,  WIDTH
      ,  CREATION_DATE
      ,  CREATED_BY
      ,  LAST_UPDATE_DATE
      ,  LAST_UPDATED_BY
      ,  LAST_UPDATE_LOGIN
      )
      VALUES
      (  p_dsb_table(i).dashboard_detail_id
      ,  p_dashboard_id
      ,  p_dsb_table(i).row_number
      ,  p_dsb_table(i).column_number
      ,  p_dsb_table(i).content_id
      ,  p_dsb_table(i).width
      ,  sysdate
      ,  fnd_global.user_id
      ,  sysdate
      ,  fnd_global.user_id
      ,  fnd_global.login_id
      );

   END LOOP;

END Generate_Default_Rows;


--========================================================================
-- PROCEDURE : DELETE_DASHBOARDS
--
-- PARAMETERS:
--             p_price_plan_id         Price plan ID for which reports needs
--                                     to be deleted
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes all the  dashboard masters and
--             corresponding records from dashboard details tables
--             for a given price plan id
--========================================================================

PROCEDURE DELETE_DASHBOARDS(
    p_price_plan_id        IN            NUMBER,
    x_return_status    OUT NOCOPY    VARCHAR2)
  IS
  l_detail_id       NUMBER;
  CURSOR Get_Dashboard_Details_C(c_price_plan_id NUMBER)
  IS
     SELECT DT.DASHBOARD_DETAIL_ID
     FROM QPR_DASHBOARD_DETAILS DT
          ,QPR_DASHBOARD_MASTER_B DMB
     WHERE DMB.DASHBOARD_ID = DT.DASHBOARD_ID
     AND   DMB.PLAN_ID = c_price_plan_id;


  BEGIN

     OPEN Get_Dashboard_Details_C(p_price_plan_id);
     LOOP
         FETCH Get_Dashboard_Details_C INTO l_detail_id;
         IF Get_Dashboard_Details_C%NOTFOUND
         THEN
             EXIT;
         END IF;

         DELETE FROM QPR_DASHBOARD_DETAILS
         WHERE DASHBOARD_DETAIL_ID = l_detail_id;
     END LOOP;
     CLOSE Get_Dashboard_Details_C;

     DELETE FROM QPR_DASHBOARD_MASTER_TL
     WHERE DASHBOARD_ID IN
       (SELECT DASHBOARD_ID
        FROM QPR_DASHBOARD_MASTER_B
        WHERE PLAN_ID = p_price_plan_id);

     DELETE FROM QPR_DASHBOARD_MASTER_B
     WHERE PLAN_ID = p_price_plan_id;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
     EXCEPTION
     WHEN OTHERS
     THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END DELETE_DASHBOARDS;


END QPR_DASHBOARD_UTIL;

/
