--------------------------------------------------------
--  DDL for Package Body CN_PAY_APPROVAL_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_APPROVAL_FLOW_PVT" AS
-- $Header: cnvpflwb.pls 120.4 2006/02/13 15:23:30 fmburu ship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_PAY_APPROVAL_FLOW_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvpflwb.pls';

--
-- Procedure : Get_Payrun_Info
--
PROCEDURE Get_Payrun_Info
  (p_worksheet_id  IN  NUMBER,
   x_period_id     OUT NOCOPY NUMBER,
   x_payrun_id     OUT NOCOPY NUMBER,
   x_resource_id   OUT NOCOPY NUMBER,
   x_user_email    OUT NOCOPY VARCHAR2) IS

BEGIN
   BEGIN
      SELECT resource_id,source_email INTO x_resource_id,x_user_email
  FROM jtf_rs_resource_extns
  WHERE user_id = fnd_global.user_id;
   EXCEPTION
      WHEN no_data_found THEN
   -- resource not exist for this user
   FND_MESSAGE.SET_NAME ('CN','CN_USER_RESOURCE_NF');
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
   END;
   BEGIN
      SELECT p.payrun_id,p.pay_period_id INTO x_payrun_id,x_period_id
  FROM cn_payment_worksheets w,cn_payruns p
  WHERE w.payment_worksheet_id = p_worksheet_id
  AND p.payrun_id = w.payrun_id
    --R12
    AND p.org_id = w.org_id
  ;
   EXCEPTION
      WHEN no_data_found THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
            FND_MESSAGE.SET_NAME ('CN','CN_WKSHT_DOES_NOT_EXIST');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
   END;
END Get_Payrun_Info ;


--
-- Procedure : Get_Mgr_List
--
PROCEDURE Get_Mgr_List
  (p_worksheet_id IN  NUMBER,
   p_action       IN VARCHAR2,
   p_payrun_id    IN NUMBER,
   p_resource_id  IN NUMBER,
   p_period_id    IN NUMBER,
   p_user_email   IN VARCHAR2) IS

      l_approval_status cn_pay_approval_flow.approval_status%TYPE;
      l_flow_rec cn_pay_approval_flow_pkg.pay_approval_flow_rec_type;

      CURSOR c_mgr_csr(c_org_id NUMBER) IS
   SELECT DISTINCT m1.parent_resource_id mgr_resource_id,
     re1.source_email mgr_email,re1.user_id mgr_user_id
     FROM cn_period_statuses pr,
     jtf_rs_group_usages u1, jtf_rs_rep_managers m1,
     jtf_rs_resource_extns re1
     WHERE pr.period_id = p_period_id
     AND     pr.org_id      = c_org_id
     AND u1.usage = 'COMP_PAYMENT'
     AND m1.resource_id = p_resource_id
     AND ((m1.start_date_active <= pr.end_date) AND
    (pr.start_date <= Nvl(m1.end_date_active,pr.start_date)))
     AND u1.group_id = m1.group_id
     AND m1.hierarchy_type IN ('MGR_TO_MGR','MGR_TO_REP')
     AND m1.category <> 'TBH'
     AND (m1.reports_to_flag = 'Y' -- Bug 2819874
    OR (m1.reports_to_flag = 'N' AND m1.denorm_level = 1))
     AND re1.resource_id = m1.parent_resource_id
     ;

    --R12
    p_org_id cn_payruns.org_id%TYPE;
    l_has_access BOOLEAN;

BEGIN

   IF p_action = 'SUBMIT' THEN
      --Added for R12 payment security check begin.
      l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_wksht,
                        CN_PAYMENT_SECURITY_PVT.g_access_wksht_submit);
      IF ( l_has_access = FALSE)
      THEN
          RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --Added for R12 payment security check end.

      l_approval_status := 'SUBMITTED';
    ELSIF p_action = 'APPROVE' THEN
      --Added for R12 payment security check begin.
      l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_wksht,
                        CN_PAYMENT_SECURITY_PVT.g_access_wksht_approve);
      IF ( l_has_access = FALSE)
      THEN
          RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --Added for R12 payment security check end.

      l_approval_status := 'APPROVED';
   END IF;

   --R12
   SELECT org_id
   INTO p_org_id
   FROM cn_payruns
   WHERE payrun_id = p_payrun_id;

   IF cn_payment_security_pvt.is_superuser(p_period_id => p_period_id,p_org_id=>p_org_id) = 1 THEN
      -- insert record into cn_pay_approval_flow
      SELECT cn_pay_approval_flow_s.NEXTVAL
  INTO l_flow_rec.pay_approval_flow_id FROM dual;
      l_flow_rec.payrun_id := p_payrun_id;
      l_flow_rec.payment_worksheet_id := p_worksheet_id;
      l_flow_rec.submit_by_resource_id := p_resource_id ;
      l_flow_rec.submit_by_user_id :=  fnd_global.user_id;
      l_flow_rec.submit_by_email := p_user_email;
      l_flow_rec.submit_to_resource_id := p_resource_id ;
      l_flow_rec.submit_to_user_id := fnd_global.user_id;
      l_flow_rec.submit_to_email := p_user_email;
      l_flow_rec.approval_status :=  l_approval_status ;
      l_flow_rec.updated_by_resource_id  := p_resource_id;
      --R12
      l_flow_rec.org_id := p_org_id;
      cn_pay_approval_flow_pkg.insert_row
  ( p_pay_approval_flow_rec => l_flow_rec);
    ELSE
      FOR l_mgr_csr IN c_mgr_csr(p_org_id) LOOP
   -- insert record into cn_pay_approval_flow
   SELECT cn_pay_approval_flow_s.NEXTVAL
     INTO l_flow_rec.pay_approval_flow_id FROM dual;
   l_flow_rec.payrun_id := p_payrun_id;
   l_flow_rec.payment_worksheet_id := p_worksheet_id;
   l_flow_rec.submit_by_resource_id := p_resource_id ;
   l_flow_rec.submit_by_user_id :=  fnd_global.user_id;
   l_flow_rec.submit_by_email := p_user_email;
   l_flow_rec.submit_to_resource_id := l_mgr_csr.mgr_resource_id ;
   l_flow_rec.submit_to_user_id := l_mgr_csr.mgr_user_id;
   l_flow_rec.submit_to_email := l_mgr_csr.mgr_email;
   l_flow_rec.approval_status :=  l_approval_status ;
   l_flow_rec.updated_by_resource_id  := p_resource_id;
      --R12
      l_flow_rec.org_id := p_org_id;
   cn_pay_approval_flow_pkg.insert_row
     ( p_pay_approval_flow_rec => l_flow_rec);
      END LOOP;
   END IF;

END Get_Mgr_List ;


-- Start of comments
--    API name        : Submit_Worksheet
--    Type            : Private.
--    Function        : submit worksheet for approval.
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_worksheet_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Submit_Worksheet
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_worksheet_id            IN     NUMBER
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Submit_Worksheet';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_payrun_id  cn_payruns.payrun_id%TYPE;
      l_resource_id jtf_rs_resource_extns.resource_id%TYPE;
      l_period_id cn_period_statuses.period_id%TYPE;
      l_user_email jtf_rs_resource_extns.source_email%TYPE;

      l_has_access BOOLEAN;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Submit_Worksheet;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body

    --Added for R12 payment security check begin.
    l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_wksht,
                        CN_PAYMENT_SECURITY_PVT.g_access_wksht_submit);
    IF ( l_has_access = FALSE)
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --Added for R12 payment security check end.

   -- delete records in CN_PAY_APPROVAL_FLOW
   DELETE FROM cn_pay_approval_flow
     WHERE payment_worksheet_id = p_worksheet_id;
   -- get_payrun_info
   Get_Payrun_Info
     (p_worksheet_id  => p_worksheet_id,
      x_period_id     => l_period_id,
      x_payrun_id     => l_payrun_id,
      x_resource_id   => l_resource_id,
      x_user_email    => l_user_email);

   -- call get_mgr_list
   Get_Mgr_List
     (p_worksheet_id => p_worksheet_id,
      p_action       => 'SUBMIT',
      p_period_id     => l_period_id,
      p_payrun_id     => l_payrun_id,
      p_resource_id   => l_resource_id,
      p_user_email    => l_user_email);

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Submit_Worksheet  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Submit_Worksheet ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

   WHEN OTHERS THEN
      ROLLBACK TO Submit_Worksheet ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

END Submit_Worksheet;

-- Start of comments
--    API name        : Approve_Worksheet
--    Type            : Private.
--    Function        : approve worksheet
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_worksheet_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Approve_Worksheet
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_worksheet_id            IN     NUMBER
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Approve_Worksheet';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_payrun_id  cn_payruns.payrun_id%TYPE;
      l_resource_id jtf_rs_resource_extns.resource_id%TYPE;
      l_period_id cn_period_statuses.period_id%TYPE;
      l_user_email jtf_rs_resource_extns.source_email%TYPE;

      l_has_access BOOLEAN;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Approve_Worksheet;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
    --Added for R12 payment security check begin.
    l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_wksht,
                        CN_PAYMENT_SECURITY_PVT.g_access_wksht_approve);
    IF ( l_has_access = FALSE)
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --Added for R12 payment security check end.

   -- get_payrun_info
   Get_Payrun_Info
     (p_worksheet_id  => p_worksheet_id,
      x_period_id     => l_period_id,
      x_payrun_id     => l_payrun_id,
      x_resource_id   => l_resource_id,
      x_user_email    => l_user_email);

   -- update pay_approval_flow record
   UPDATE cn_pay_approval_flow
     SET approval_status = 'APPROVED', updated_by_resource_id = l_resource_id,
     last_updated_by = fnd_global.user_id,
     last_update_date = Sysdate,
     last_update_login = fnd_global.login_id
     WHERE payment_worksheet_id = p_worksheet_id
     ;

   -- call get_mgr_list
   Get_Mgr_List
     (p_worksheet_id => p_worksheet_id,
      p_action       => 'APPROVE',
      p_period_id     => l_period_id,
      p_payrun_id     => l_payrun_id,
      p_resource_id   => l_resource_id,
      p_user_email    => l_user_email);

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Approve_Worksheet  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Approve_Worksheet ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

   WHEN OTHERS THEN
      ROLLBACK TO Approve_Worksheet ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

END Approve_Worksheet;

-- Start of comments
--    API name        : Reject_Worksheet
--    Type            : Private.
--    Function        : reject worksheet
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_worksheet_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Reject_Worksheet
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_worksheet_id            IN     NUMBER
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Reject_Worksheet';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_payrun_id  cn_payruns.payrun_id%TYPE;
      l_resource_id jtf_rs_resource_extns.resource_id%TYPE;
      l_period_id cn_period_statuses.period_id%TYPE;
      l_user_email jtf_rs_resource_extns.source_email%TYPE;

      l_has_access BOOLEAN;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Reject_Worksheet;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body

    --Added for R12 payment security check begin.
    l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_wksht,
                        CN_PAYMENT_SECURITY_PVT.g_access_wksht_reject);
    IF ( l_has_access = FALSE)
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --Added for R12 payment security check end.

   -- get_payrun_info
   Get_Payrun_Info
     (p_worksheet_id  => p_worksheet_id,
      x_period_id     => l_period_id,
      x_payrun_id     => l_payrun_id,
      x_resource_id   => l_resource_id,
      x_user_email    => l_user_email);

   -- update pay_approval_flow record
   UPDATE cn_pay_approval_flow
     SET approval_status = 'REJECTED', updated_by_resource_id = l_resource_id,
     last_updated_by = fnd_global.user_id,
     last_update_date = Sysdate,
     last_update_login = fnd_global.login_id
     WHERE payment_worksheet_id = p_worksheet_id
     ;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Reject_Worksheet  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Reject_Worksheet ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

   WHEN OTHERS THEN
      ROLLBACK TO Reject_Worksheet ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

END Reject_Worksheet;

-- Start of comments
--    API name        : Pay_Payrun
--    Type            : Private.
--    Function        : pay payrun
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_payrun_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Pay_Payrun
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_payrun_id               IN     NUMBER
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Pay_Payrun';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_has_access BOOLEAN;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Pay_Payrun_Flow;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body

    --Added for R12 payment security check begin.
    l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_payrun,
                        CN_PAYMENT_SECURITY_PVT.g_access_payrun_pay);
    IF ( l_has_access = FALSE)
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --Added for R12 payment security check end.

   -- delete record
   DELETE FROM cn_pay_approval_flow
     WHERE payrun_id = p_payrun_id
     ;
   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Pay_Payrun_Flow  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Pay_Payrun_Flow ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

   WHEN OTHERS THEN
      ROLLBACK TO Pay_Payrun_Flow ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE);

END Pay_Payrun;

END CN_PAY_APPROVAL_FLOW_PVT ;

/
