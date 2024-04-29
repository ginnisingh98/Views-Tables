--------------------------------------------------------
--  DDL for Package Body PA_PERIOD_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERIOD_PROCESS_PKG" as
-- $Header: PAGLPKGB.pls 120.2 2006/07/14 06:18:17 anuagraw noship $

    G_PrevOrgId     NUMBER;
    G_PrevRetValue  VARCHAR2(30);

--
-- Function             : Is_Enabled
-- Purpose              : This functions returns true if the profile option
--                        PA_EN_NEW_GLDATE_DERIVATION is set as 'Y' otherwise flase.
-- Parameters           : None.
--

FUNCTION Is_Enabled RETURN VARCHAR2 IS

l_return_value                  VARCHAR(30);
BEGIN

 IF PA_PERIOD_PROCESS_PKG.Enable_New_GL_Date_Der is NULL THEN
     FND_PROFILE.GET('PA_EN_NEW_GLDATE_DERIVATION',l_return_value );

     if ( l_return_value = 'Y' ) then
        PA_PERIOD_PROCESS_PKG.Enable_New_GL_Date_Der := 'Y' ;
     else
        PA_PERIOD_PROCESS_PKG.Enable_New_GL_Date_Der := 'N' ;
     end if;
 END IF;
 return (PA_PERIOD_PROCESS_PKG.Enable_New_GL_Date_Der) ;

END Is_enabled ;

--
-- Function             : Application_Id
-- Purpose              : This functions returns true if the profile option
--                        PA_EN_NEW_GLDATE_DERIVATION is set as 'Y' otherwise flase.
-- Parameters           : None.
--

FUNCTION Application_Id RETURN NUMBER IS

l_return_value                  VARCHAR(30);
BEGIN

 IF PA_PERIOD_PROCESS_PKG.G_Application_Id is NULL THEN
     FND_PROFILE.GET('PA_EN_NEW_GLDATE_DERIVATION',l_return_value );

     if ( l_return_value = 'Y' ) then
        PA_PERIOD_PROCESS_PKG.G_Application_Id := 8721 ;
     else
        PA_PERIOD_PROCESS_PKG.G_Application_Id := 101 ;
     end if;
 END IF;
 return (PA_PERIOD_PROCESS_PKG.G_Application_Id) ;

END Application_Id ;

--
-- Function             : Use_Same_PA_GL_Period
-- Purpose              : This functions returns 'Y' if the implementation option
--                        Maintain Common PA and GL Periods is set as 'Y' otherwise 'N'.
-- Parameters           : None.
--
-- Bug#2103722
--   Added new parameter p_org_id and necessary join.
--

FUNCTION Use_Same_PA_GL_Period(p_org_id IN pa_implementations_all.org_id%TYPE) RETURN VARCHAR2 IS
 l_return_value                  VARCHAR(30);
BEGIN

 If G_PrevOrgId = nvl(p_org_id,-99) Then

    l_return_value := G_PrevRetValue;

 Else

    select nvl(imp.same_pa_gl_period,'N')
    into l_return_value
    from pa_implementations_all imp
    where imp.org_id = nvl(p_org_id, -99);                       /*5368274*/

    G_PrevOrgId := nvl(p_org_id,-99);
    G_PrevRetValue := l_return_value;

 End If;

 return (l_return_value) ;

EXCEPTION
 when others then
  G_PrevOrgId := nvl(p_org_id,-99);
  G_PrevRetValue := 'N';
  return 'N';
END Use_Same_PA_GL_Period ;

--
-- Procedure            : Update_PA_Period_Status
-- Purpose              : This procedure will update the PA period status when the
--                        Implementation option - Maintain Common PA and GL Periods
--                        is set to Yes and the Profile - Enable Enhanced Period
--                        Processing is set to Yes.
--                        This API is called from the GL Periods Form - PAXPAGLP.fmb
-- Parameters           : None.
--
PROCEDURE Update_PA_Period_Status is

 cursor c_periods is
 select b.period_name, b.closing_status, b.set_of_books_id ,
        b.last_update_date, b.last_updated_by, b.last_update_login /* added bug 3111150 */
 from pa_periods a, gl_period_statuses b
 where a.period_name = b.period_name
 and b.application_id = 8721
 and b.set_of_books_id = (select set_of_books_id from pa_implementations)
 and a.start_date = b.start_date
 and a.end_Date = b.end_date
 and a.status <> b.closing_status;

 l_PeriodTab  PA_PLSQL_DATATYPES.Char15TabTyp;
 l_StatusTab  PA_PLSQL_DATATYPES.Char1TabTyp;
 l_SobId      PA_PLSQL_DATATYPES.IdTabTyp;
 l_LastUpdateDate      PA_PLSQL_DATATYPES.DateTabTyp; /* added bug 3111150 */
 l_LastUpdatedBy       PA_PLSQL_DATATYPES.IdTabTyp;   /* added bug 3111150 */
 l_LastUpdateLogin     PA_PLSQL_DATATYPES.IdTabTyp;   /* added bug 3111150 */

begin
 open c_periods;
 loop
    l_PeriodTab.Delete;
    l_StatusTab.Delete;
    l_SobId.Delete;
    l_LastUpdateDate.Delete;    /* added bug 3111150 */
    l_LastUpdatedBy.Delete;     /* added bug 3111150 */
    l_LastUpdateLogin.Delete;   /* added bug 3111150 */

    fetch c_periods bulk collect into
        l_PeriodTab,
        l_StatusTab,
        l_SobId,
        l_LastUpdateDate,    /* added bug 3111150 */
        l_LastUpdatedBy,     /* added bug 3111150 */
        l_LastUpdateLogin    /* added bug 3111150 */
    limit 200;

    if l_PeriodTab.count = 0 then
        exit;
    end if;

    forall i in l_PeriodTab.first..l_PeriodTab.last
      update pa_periods_all pp
      set pp.status = l_StatusTab(i),
          pp.last_update_date = l_LastUpdateDate(i),     /* added bug 3111150 */
          pp.last_updated_by = l_LastUpdatedBy(i),       /* added bug 3111150 */
          pp.last_update_login = l_LastUpdateLogin(i)    /* added bug 3111150 */
      where pp.period_name = l_PeriodTab(i)
      and pp.org_id in (select imp.org_id
                       from pa_implementations_all imp
                       where nvl(imp.same_pa_gl_period,'N') = 'Y'
                       and imp.set_of_books_id = l_SobId(i));

    commit;
    exit when c_periods%notfound;
  end loop;
  close c_periods;

exception
  when others then
     IF c_periods%ISOPEN THEN
        close c_periods;
     END IF;
     raise;
end Update_PA_Period_Status;

--Procedure            : Check_Imp_Option_Controls
--Purpose              : This procedure is called from the implementation form
--                       when the user changes the option - Maintain Common PA
--                       and GL Periods from N to Y.
--                       The checks that are performed are as follows:
--                       1. See if the calendar and period_type for GL and PA
--                          period are the same
--                       2. Check if the profile PA: Enable Enhanced Period Processing
--                          is enabled.
--                       3. Check if the PA period status is in sync with the GL period
--                          status
PROCEDURE Check_Imp_Option_Controls(
                         p_period_set_name in varchar2,
                         p_pa_period_type  in varchar2,
                         p_sob_id          in number,
                         p_org_id          in number,
                         x_return_status   out nocopy varchar2,
                         x_error_message_code out nocopy varchar2) AS

   lv_period_set_name     VARCHAR2(30);
   lv_pa_period_type      VARCHAR2(30);
   lv_sob_id              NUMBER;
   lv_org_id              NUMBER;
   lv_gl_period_type      VARCHAR2(30);
   lv_gl_period_set_name  VARCHAR2(30);
   lv_enabled_flag        VARCHAR2(30);
   lv_pa_period_name      VARCHAR2(30);
   lv_return_status       VARCHAR2(30);
   lv_error_message_code  VARCHAR2(30);
   lv_exception           EXCEPTION;

--This cursor is used to check whether there are any periods
--where the the pa_period staus does not match the gl_period status
CURSOR c_Mismatch_Status IS
   SELECT pa.period_name
     FROM pa_periods pa,
          gl_period_statuses gl
     WHERE gl.set_of_books_id=p_sob_id
       AND gl.application_id=8721
       AND pa.period_name=gl.period_name
       AND pa.status <>gl.closing_status;

BEGIN

  SELECT Period_Set_Name,
         Accounted_Period_Type
   INTO lv_gl_period_set_name,
         lv_gl_period_type
    FROM gl_sets_of_books
      WHERE Set_of_Books_ID=p_sob_id;

-- This SELECT statement is used to check whether the GL Period Name and
-- type match those on the PA side

   IF lv_gl_period_set_name = p_period_set_name AND
      lv_gl_period_type = p_pa_period_type THEN

--Calling the function to check whether the option in implementation is turned on

      lv_enabled_flag := PA_PERIOD_PROCESS_PKG.IS_Enabled;

      IF lv_enabled_flag='Y' THEN

         OPEN  c_Mismatch_Status;

         LOOP

           FETCH c_Mismatch_Status INTO lv_pa_period_name;

           IF c_Mismatch_Status%NOTFOUND  THEN

           lv_return_status:='S';
           EXIT;

           ELSIF lv_pa_period_name IS NOT NULL THEN

            lv_error_message_code:='PA_GL_PER_STS_MISMATCH';
            lv_return_status:='F';
            EXIT;
           END IF;

         END LOOP;

     ELSE

          lv_error_message_code:='PA_GL_PER_IMP_NOT_ENABLED';
          lv_return_status:='F';

      END IF;

   ELSE

          lv_error_message_code:='PA_GL_PER_TYP_MISMATCH';
          lv_return_status:='F';

   END IF;

   x_return_status:=lv_return_status;
   x_error_message_code:=lv_error_message_code;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'F';
      x_error_message_code := Null;
      RAISE;

END Check_Imp_Option_Controls;

END PA_PERIOD_PROCESS_PKG;

/
