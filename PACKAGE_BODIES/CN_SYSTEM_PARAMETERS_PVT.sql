--------------------------------------------------------
--  DDL for Package Body CN_SYSTEM_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SYSTEM_PARAMETERS_PVT" AS
/*$Header: cnvsyspb.pls 115.9 2003/05/02 08:10:35 hithanki ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'CN_SYSTEM_PARAMETERS_PVT';

PROCEDURE Get_Data
  (x_name                    OUT NOCOPY VARCHAR2,
   x_status                  OUT NOCOPY VARCHAR2,
   x_status_code             OUT NOCOPY VARCHAR2,
   x_rev_class_hierarchy_id  OUT NOCOPY NUMBER,
   x_set_of_books_id         OUT NOCOPY NUMBER,
   x_sob_name                OUT NOCOPY VARCHAR2,
   x_sob_currency            OUT NOCOPY VARCHAR2,
   x_sob_calendar            OUT NOCOPY VARCHAR2,
   x_sob_period_type         OUT NOCOPY VARCHAR2,
   x_batch_size              OUT NOCOPY NUMBER,
   x_transfer_batch_size     OUT NOCOPY NUMBER,
   x_clawback_grace_days     OUT NOCOPY NUMBER,
   x_transaction_batch_size  OUT NOCOPY NUMBER,
   x_managerial_rollup       OUT NOCOPY VARCHAR2,
   x_latest_processed_date   OUT NOCOPY DATE,
   x_salesperson_batch_size  OUT NOCOPY NUMBER,
   x_rule_batch_size         OUT NOCOPY NUMBER,
   x_payables_flag           OUT NOCOPY VARCHAR2,
   x_payroll_flag            OUT NOCOPY VARCHAR2,
   x_payables_ccid_level     OUT NOCOPY VARCHAR2,
   x_usage_flag             OUT NOCOPY VARCHAR2,
   x_income_planner_disclaimer  OUT NOCOPY VARCHAR2,
   x_object_version_number   OUT NOCOPY NUMBER) IS

   CURSOR c is
   select name, status, rev_class_hierarchy_id, set_of_books_id,
          system_batch_size, transfer_batch_size, clawback_grace_days,
          srp_batch_size, srp_rollup_flag, latest_processed_date, usage_flag,
          salesrep_batch_size, cls_package_size, payables_flag, payroll_flag,
          payables_ccid_level, income_planner_disclaimer,object_version_number
     FROM cn_repositories
    WHERE application_type = 'CN' and repository_id > 0;

   r c%rowtype;
   junk varchar2(30);
BEGIN
   open  c;
   fetch c into r;
   close c;

   -- copy over information, avoiding nulls
   x_name                   := r.name;
   x_rev_class_hierarchy_id := nvl(r.rev_class_hierarchy_id, -1);
   x_set_of_books_id        := r.set_of_books_id;
   x_batch_size             := nvl(r.system_batch_size, 5000);
   x_transfer_batch_size    := nvl(r.transfer_batch_size, 5000);
   x_clawback_grace_days    := nvl(r.clawback_grace_days, 0);
   x_transaction_batch_size := nvl(r.srp_batch_size, 0);
   x_managerial_rollup      := nvl(r.srp_rollup_flag, 'N');
   x_latest_processed_date  := r.latest_processed_date;
   x_salesperson_batch_size := nvl(r.salesrep_batch_size, 0);
   x_rule_batch_size        := nvl(r.cls_package_size,0);
   x_payables_flag          := nvl(r.payables_flag, 'N');
   x_payroll_flag           := nvl(r.payroll_flag,  'N');
   x_payables_ccid_level    := r.payables_ccid_level;
   x_usage_flag             := nvl(r.usage_flag, 'A');
   x_income_planner_disclaimer := r.income_planner_disclaimer;
   x_object_version_number  := r.object_version_number;
   x_status_code            := r.status;

   -- call old forms API
   CNSYSP_system_parameters_PKG.Populate_Fields
     (x_set_of_books_id               => r.set_of_books_id,
      x_trx_rollup_method             => null, -- not used
      x_usage_flag                    => null, -- not used
      x_status                        => r.status,
      x_sob_name                      => x_sob_name,
      x_sob_calendar                  => x_sob_calendar,
      x_sob_period_type               => x_sob_period_type,
      x_sob_currency                  => x_sob_currency,
      x_trx_rollup_method_string      => junk,
      x_usage_string                  => junk,
      x_status_string                 => x_status);

END Get_Data;

PROCEDURE Update_Data
   (p_api_version             IN      NUMBER                          ,
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_commit                  IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_validation_level        IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_name                    IN      VARCHAR2,
    p_rev_class_hierarchy_id  IN      NUMBER,
    p_set_of_books_id         IN      NUMBER,
    p_batch_size              IN      NUMBER,
    p_transfer_batch_size     IN      NUMBER,
    p_clawback_grace_days     IN      NUMBER,
    p_transaction_batch_size  IN      NUMBER,
    p_managerial_rollup       IN      VARCHAR2,
    p_salesperson_batch_size  IN      NUMBER,
    p_rule_batch_size         IN      NUMBER,
    p_payables_flag           IN      VARCHAR2,
    p_payroll_flag            IN      VARCHAR2,
    p_payables_ccid_level     IN      VARCHAR2,
    p_income_planner_disclaimer  IN   VARCHAR2,
    p_object_version_number   IN      NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2                        ,
    x_msg_count               OUT NOCOPY     NUMBER                          ,
    x_msg_data                OUT NOCOPY     VARCHAR2                        ) IS

    l_api_name                CONSTANT VARCHAR2(30) := 'Update_Data';
    l_api_version             CONSTANT NUMBER       := 1.0;

   cursor c is
   select object_version_number
     from cn_repositories
    where application_type = 'CN'
      and repository_id > 0
      for update of repository_id nowait;

   tlinfo c%rowtype ;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Data;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
      G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   -- locking
   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   close c;

   if (tlinfo.object_version_number <> p_object_version_number) then
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;

   -- updating
   update cn_repositories
      set name                   = p_name,
          rev_class_hierarchy_id = p_rev_class_hierarchy_id,
          set_of_books_id        = p_set_of_books_id,
          system_batch_size      = p_batch_size,
          transfer_batch_size    = p_transfer_batch_size,
          clawback_grace_days    = p_clawback_grace_days,
          srp_batch_size         = p_transaction_batch_size,
          srp_rollup_flag        = p_managerial_rollup,
          salesrep_batch_size    = p_salesperson_batch_size,
          cls_package_size       = decode(p_rule_batch_size, 0, null,
					  p_rule_batch_size), -- 0 = null
          payables_flag          = p_payables_flag,
          payroll_flag           = p_payroll_flag,
          payables_ccid_level    = p_payables_ccid_level,
          income_planner_disclaimer = p_income_planner_disclaimer,
          last_update_date       = sysdate,
          last_updated_by        = fnd_global.user_id,
          last_update_login      = fnd_global.login_id,
          object_version_number  = object_version_number + 1
    where application_type = 'CN'
      and repository_id > 0;

   -- data fix for bug 1358579 built into original CNSYSP forms logic
   insert into cn_period_sets
     ( period_set_id,
       period_set_name,
       created_by,
       creation_date )
     select 0,
            gl.period_set_name,
            -1,
            SYSDATE
       from cn_repositories r,
            gl_sets_of_books gl
      where gl.set_of_books_id = r.set_of_books_id
        and not exists
     ( select 1 from cn_period_sets where period_set_id = 0 );


   insert into cn_period_types
     ( period_type_id,
       period_type,
       created_by,
       creation_date )
     select 0,
            gl.accounted_period_type,
            -1,
            SYSDATE
       from cn_repositories r,
            gl_sets_of_books gl
      where gl.set_of_books_id = r.set_of_books_id
        and not exists
     ( select 1 from cn_period_types where period_type_id = 0 );

   update cn_repositories
      set period_set_id = 0 ,
          period_type_id = 0
    where set_of_books_id is not null;

   update cn_period_types
      set period_type = 'Period'
    where period_type_id = -1000
      and period_type = 'Month';

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Data;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Data;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Data;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Update_Data;
END CN_SYSTEM_PARAMETERS_PVT;

/
