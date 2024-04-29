--------------------------------------------------------
--  DDL for Package Body CN_PMTSUB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMTSUB_PUB" as
-- $Header: cnppsubb.pls 120.3 2005/11/07 22:41:57 sjustina noship $

--============================================================================
--Name :Pay_Payrun_conc
--Description : Procedure which will be used as the executable for the concurrent
--              program CN_PAY_PAYRUN
--
--============================================================================
PROCEDURE Pay_Payrun_conc
     ( errbuf  OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY NUMBER ,
    p_name            cn_payruns.name%TYPE ) IS

     l_proc_audit_id NUMBER;
     l_return_status VARCHAR2(1000);
     l_msg_data      VARCHAR2(2000);
     l_msg_count     NUMBER;
     l_loading_status VARCHAR2(1000);
     l_status VARCHAR2(2000);
     l_org_id  NUMBER ;


BEGIN

   retcode := 0;
   -- Initial message list
   FND_MSG_PUB.initialize;

   l_org_id   := mo_global.get_current_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id, status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_pmtsub_pub.pay_payrun_conc.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;

   IF l_org_id IS NULL THEN
    fnd_message.set_name('FND', 'MO_OU_REQUIRED');
    fnd_msg_pub.ADD;
    RAISE FND_API.G_EXC_ERROR;
   END IF;

   cn_message_pkg.begin_batch

     ( x_process_type            => 'PMT',
       x_process_audit_id        => l_proc_audit_id,
       x_parent_proc_audit_id    => l_proc_audit_id,
       x_request_id              => NULL,
       p_org_id                  => l_org_id
       );
   cn_message_pkg.debug('***************************************************');
   cn_message_pkg.debug('Processing payment');

   Pay
     (  p_api_version => 1.0,
  p_init_msg_list => fnd_api.g_true,
        p_commit => fnd_api.g_true,
  x_return_status => l_return_status,
  x_msg_count => l_msg_count,
  x_msg_data => l_msg_data,
  p_payrun_name => p_name,
     p_org_id                  => l_org_id,
        x_loading_status => l_loading_status,
  x_status => l_status
  );

 IF l_return_status <> FND_API.g_ret_sts_success
   THEN
    retcode := 2;
    errbuf := FND_MSG_PUB.get(p_msg_index => fnd_msg_pub.G_LAST,
            p_encoded   => FND_API.G_FALSE);
    cn_message_pkg.debug('Error for payrun : '||errbuf);

  ELSE
    COMMIT;
 END IF;
END;
--============================================================================
-- Procedure : Pay
-- Description: To pay a payrun
--              Update the subledger
--============================================================================

   PROCEDURE  Pay
   (    p_api_version     IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2,
  p_commit          IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
        x_return_status          OUT NOCOPY   VARCHAR2,
      x_msg_count            OUT NOCOPY   NUMBER,
      x_msg_data       OUT NOCOPY   VARCHAR2,
      p_payrun_name                   IN      cn_payruns.name%TYPE,
      p_org_id              IN NUMBER,
      x_status               OUT NOCOPY   VARCHAR2,
      x_loading_status       OUT NOCOPY   VARCHAR2
    ) IS

      l_api_name    CONSTANT VARCHAR2(30)  := 'Pay';
      l_api_version             CONSTANT NUMBER        := 1.0;

      l_payrun_id               NUMBER;
      l_org_id                  NUMBER;
      l_status      CN_PAYRUNS.STATUS%TYPE;

      l_payrun_name             cn_payruns.name%TYPE;
      l_OAI_array   JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id            NUMBER;
      l_ovn    Number ;

      l_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtSub_PUB';

   BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Pay;
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
          p_api_version ,
          l_api_name    ,
          l_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   --
   -- Assign the parameter to a local variable
   --
   l_payrun_name := p_payrun_name;
   l_org_id :=  p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id, status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_pmtsub_pub.pay.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;


   IF l_org_id IS NULL THEN
    fnd_message.set_name('FND', 'MO_OU_REQUIRED');
    fnd_msg_pub.ADD;
    RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   -- User hooks
   --

   IF JTF_USR_HKS.Ok_to_Execute('CN_PMTSUB_PUB',
        'PAY',
        'B',
        'C')
     THEN
      cn_pmtsub_pub_cuhk.pay_pre
  (p_api_version            => p_api_version,
   p_init_msg_list    => fnd_api.g_false,
   p_commit         => fnd_api.g_false,
   p_validation_level   => p_validation_level,
   x_return_status    => x_return_status,
   x_msg_count      => x_msg_count,
   x_msg_data     => x_msg_data,
   p_payrun_name                  => l_payrun_name,
    p_payrun_id         => l_payrun_id,
   x_loading_status   => x_loading_status,
   x_status                       => x_status
   );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
  THEN
   RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
   THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_PMTSUB_PUB',
        'PAY',
        'B',
        'V')
     THEN
      cn_pmtsub_pub_vuhk.pay_pre
  (p_api_version            => p_api_version,
   p_init_msg_list    => fnd_api.g_false,
   p_commit         => fnd_api.g_false,
   p_validation_level   => p_validation_level,
   x_return_status    => x_return_status,
   x_msg_count      => x_msg_count,
   x_msg_data     => x_msg_data,
   p_payrun_name                  => l_payrun_name,
   p_payrun_id         => l_payrun_id,
   x_loading_status   => x_loading_status,
   x_status                       => x_status
   );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
  THEN
   RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
   THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


    -- Added Exception and for update
    BEGIN
      SELECT payrun_id, status, object_version_number
        INTO l_payrun_id, l_status, l_ovn
        FROM cn_payruns
       WHERE name = p_payrun_name
       AND org_id=l_org_id
         FOR update of payrun_id;

       IF l_status = 'PAID' THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
             THEN
              fnd_message.set_name('CN', 'CN_PAYRUN_ALREADY_PAID');
              fnd_msg_pub.add;
             END IF;
             x_loading_status := 'CN_PAYRUN_ALREADY_PAID';
             RAISE FND_API.G_EXC_ERROR;
       END IF;

    EXCEPTION
        WHEN no_data_found THEN

             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
             THEN
              fnd_message.set_name('CN', 'CN_PAYRUN_DOES_NOT_EXIST');
              fnd_msg_pub.add;
             END IF;
       x_loading_status := 'CN_PAYRUN_DOES_NOT_EXIST';
       RAISE FND_API.G_EXC_ERROR;
    END ;

   --
   -- API body
   --

   cn_payrun_pvt.pay_payrun
     (  p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => fnd_api.g_false,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_payrun_id           => l_payrun_id,
        p_x_obj_ver_number    => l_ovn,
        x_status              => x_status,
        x_loading_status      => x_loading_status);

   --
   -- End of API body
   --


   --
   -- Post processing hooks
   --


   IF JTF_USR_HKS.Ok_to_Execute('CN_PMTSUB_PUB',
        'PAY',
        'A',
        'V')
     THEN
      cn_pmtsub_pub_vuhk.pay_post
  (p_api_version            => p_api_version,
   p_init_msg_list    => fnd_api.g_false,
   p_commit         => fnd_api.g_false,
   p_validation_level   => p_validation_level,
   x_return_status    => x_return_status,
   x_msg_count      => x_msg_count,
   x_msg_data     => x_msg_data,
         p_payrun_name                  => l_payrun_name,
             p_payrun_id         => l_payrun_id,
   x_loading_status   => x_loading_status,
   x_status                       => x_status
   );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
  THEN
   RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
   THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_PMTSUB_PUB',
              'PAY',
        'A',
        'C')
     THEN
      cn_pmtsub_pub_cuhk.pay_post
  (p_api_version            => p_api_version,
   p_init_msg_list    => fnd_api.g_false,
   p_commit         => fnd_api.g_false,
   p_validation_level   => p_validation_level,
   x_return_status    => x_return_status,
   x_msg_count      => x_msg_count,
   x_msg_data     => x_msg_data,
   p_payrun_name                  => l_payrun_name,
       p_payrun_id         => l_payrun_id,
   x_loading_status   => x_loading_status,
   x_status                       => x_status
   );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
  THEN
   RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
   THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_execute('CN_PMTSUB_PUB',
        'PAY',
        'M',
        'M')
     THEN
      IF  cn_pmtsub_pub_cuhk.ok_to_generate_msg
   (p_payrun_name         => l_payrun_name)
  THEN
   -- Get a ID for workflow/ business object instance
   l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

    --  Do this for all the bind variables in the Business Object
   JTF_USR_HKS.load_bind_data
     (  l_bind_data_id, 'PAYRUN_NAME', l_payrun_name, 'S', 'S');

   -- Message generation API
   JTF_USR_HKS.generate_message
     (p_prod_code    => 'CN',
      p_bus_obj_code => 'PAYRUN',
      p_bus_obj_name => 'PAYRUN',
      p_action_code  => 'I',
      p_bind_data_id => l_payrun_name,
      p_oai_param    => null,
      p_oai_array    => l_oai_array,
      x_return_code  => x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_ERROR)
     THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
      END IF;
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Pay;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Pay;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN OTHERS THEN
      ROLLBACK TO Pay;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( l_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
END Pay;
--============================================================================
 PROCEDURE submit_request (p_payrun_id    IN   NUMBER,
                            x_request_id    OUT NOCOPY  NUMBER) IS

    l_request_id                 NUMBER := 0;


   CURSOR get_payrun IS
   SELECT name
     FROM cn_payruns
    WHERE payrun_id = p_payrun_id
     AND  status = 'UNPAID';

   l_name cn_payruns.name%TYPE;

   l_ret_code  VArchar2(2000);
   l_error_buf varchar2(2000);

  BEGIN

    if p_payrun_id is not null THEN

      open get_payrun;
      fetch get_payrun into l_name;
      close get_payrun;

    end if;

    if l_name is not null THEN

    /*  Pay_Payrun_conc
     ( errbuf   => l_error_buf,
       retcode  => l_ret_code,
       p_name   => l_name );
    */

     l_request_id := FND_REQUEST.SUBMIT_REQUEST('CN', 'CN_PAY_PAYRUN',
                         '', '', FALSE,
                         l_name, chr(0),
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '', '', '', '',
                         '', '', '', '', '', '', '','');
    END IF;

    x_request_id := l_request_id;

  END submit_request;




END CN_PmtSub_PUB ;

/
