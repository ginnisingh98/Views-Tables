--------------------------------------------------------
--  DDL for Package Body CN_PAYRUN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYRUN_PVT" as
-- $Header: cnvprunb.pls 120.20.12010000.3 2009/07/15 08:31:49 rajukum ship $

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CN_Payrun_PVT';

-- ===========================================================================
--   Procedure   : Build_Parse_Fetch_Call
--   Description : Procedure will be called from BUILD_BEE_API for
--       every salesrep, quota_id, element type id
-- ===========================================================================

PROCEDURE  Refresh_Payrun
( p_api_version     IN  NUMBER,
p_init_msg_list           IN  VARCHAR2,
p_commit          IN    VARCHAR2,
p_validation_level    IN    NUMBER,
p_payrun_id                   IN      cn_payruns.payrun_id%TYPE,
x_return_status          OUT NOCOPY   VARCHAR2,
x_msg_count            OUT NOCOPY   NUMBER,
x_msg_data       OUT NOCOPY   VARCHAR2,
x_status               OUT NOCOPY   VARCHAR2,
x_loading_status       OUT NOCOPY   VARCHAR2
) IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Refresh_Payrun';
  l_api_version           CONSTANT NUMBER   := 1.0;

  CURSOR get_old_record IS
  SELECT status, payrun_id,org_id,object_version_number
  FROM cn_payruns
  WHERE payrun_id = p_payrun_id;
  l_old_record get_old_record%ROWTYPE;

    CURSOR get_worksheets(p_org_id cn_payruns.org_id%TYPE) IS
    SELECT payment_worksheet_id,object_version_number
    FROM cn_payment_worksheets
    WHERE payrun_id = p_payrun_id
    AND quota_id IS NULL
    AND worksheet_status = 'UNPAID'
       --R12
    AND org_id = p_org_id;


BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT    Refresh_Payrun;
  --
  -- Standard call to check for call compatibility.
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version ,
          p_api_version ,
          l_api_name    ,
          G_PKG_NAME )
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
  x_loading_status := 'CN_DELETED';
  --
  -- API Body
  --

  OPEN get_old_record;
  FETCH get_old_record INTO l_old_record;

  IF get_old_record%rowcount = 0 THEN
    --Error condition
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)THEN
    fnd_message.set_name('CN', 'CN_PAYRUN_DOES_NOT_EXIST');
    fnd_msg_pub.add;
    END IF;
  x_loading_status := 'CN_PAYRUN_DOES_NOT_EXIST';
  RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_record;

  IF l_old_record.status IN ('PAID', 'RETURNED_FUNDS', 'PAID_WITH_RETURNS') THEN
    --Error condition
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)THEN
     fnd_message.set_name('CN', 'CN_PAYRUN_PAID');
     fnd_msg_pub.add;
    END IF;
  x_loading_status := 'CN_PAYRUN_PAID';
  RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_old_record.status = 'FROZEN' THEN
    --Error condition
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)THEN
        fnd_message.set_name('CN', 'CN_PAYRUN_FROZEN');
        fnd_msg_pub.add;
           END IF;
           x_loading_status := 'CN_PAYRUN_FROZEN';
     RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Section included by Sundar Venkat on 07 Mar 2002
       -- Procedure to check if the payrun action is valid.
  CN_PAYMENT_SECURITY_PVT.Payrun_Action
   ( p_api_version       => 1.0,
     p_init_msg_list     => fnd_api.g_true,
     p_validation_level  => fnd_api.g_valid_level_full,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,
     p_payrun_id         => p_payrun_id,
     p_action            => 'REFRESH'
   );

  IF x_return_status <> FND_API.g_ret_sts_success
    THEN
    RAISE FND_API.G_EXC_ERROR;
    END IF;


    FOR worksheets in get_worksheets(l_old_record.org_id)
    LOOP
      cn_payment_worksheet_pvt.update_Worksheet
      (p_api_version      => p_api_version,
       p_init_msg_list      => p_init_msg_list,
       p_commit           => fnd_api.g_false,
       p_validation_level => p_validation_level,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data       => x_msg_data,
       p_worksheet_id       => worksheets.payment_worksheet_id,
       p_operation      => 'REFRESH',
       x_status             => x_status,
       x_loading_status     => x_loading_status,
       --R12
       x_ovn                => worksheets.object_version_number );

      IF x_return_status <> FND_API.g_ret_sts_success
      THEN
      RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;


  -- End of API body.
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
  ROLLBACK TO Refresh_Payrun;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Refresh_Payrun;
  x_loading_status := 'UNEXPECTED_ERR';
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data   ,
  p_encoded => FND_API.G_FALSE
  );
  WHEN OTHERS THEN
  ROLLBACK TO Refresh_Payrun;
  x_loading_status := 'UNEXPECTED_ERR';
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
  FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );

END;
-- ===========================================================================
--   Procedure   : Build_Parse_Fetch_Call
--   Description : Procedure will be called from BUILD_BEE_API for
--       every salesrep, quota_id, element type id
-- ===========================================================================

PROCEDURE Build_Parse_Fetch_Call
  (x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_payrun_id          IN  NUMBER,
   p_salesrep_id        IN  NUMBER,
   p_element_type_id    IN  NUMBER,
   p_quota_id     IN  NUMBER,
   p_Incentive_type_code IN  VARCHAR2,
   p_amount   IN  NUMBER,
   p_loading_status     IN  VARCHAR2,
   x_loading_status     OUT NOCOPY VARCHAR2,
   x_batch_id   IN OUT NOCOPY NUMBER ) IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Build_Parse_Fetch_Call';
      l_flag_payment_transactions VARCHAR2(1) := 'N';


   CURSOR get_payruns IS
    SELECT name,
           org_id,
           pay_period_id,
           pay_date
      FROM cn_payruns
    WHERE payrun_id = p_payrun_id ;

    l_payrun_rec  get_payruns%ROWTYPE;

   --
   -- get the assignment id and business group id
   --
   CURSOR get_assign_id  (p_org_id      cn_payment_transactions.org_id%TYPE ) IS
     SELECT p.assignment_id assignment_id,
            p.assignment_number assignment_number,
            rre.source_business_grp_id source_business_grp_id,
      rs.status status
       FROM jtf_rs_salesreps rs,
            jtf_rs_resource_extns rre,
            per_assignments_f p,
            cn_payruns ps
     WHERE  rs.salesrep_id = p_salesrep_id
       AND  rs.org_id      = p_org_id
       AND  rs.resource_id = rre.resource_id
       AND  rre.category   = 'EMPLOYEE'
       AND  rre.source_id  = p.person_id
       AND  ps.payrun_id   = p_payrun_id
       AND  ps.pay_date  BETWEEN p.effective_start_date AND Nvl(p.effective_end_date,ps.pay_date) AND  p.assignment_type = 'E';

      l_assignment_rec get_assign_id%ROWTYPE;

    --
    -- Get the Element Inputs
    --
    -- Bug 2880233: onlt pmtpln_rec need hard code quota_id
    -- Bug 3504917: order by should be display_seq, then name
     CURSOR pay_element_inputs ( p_status    IN VARCHAR2,
         p_currency_code   IN VARCHAR2 ) IS
       SELECT tab.name table_name , col.name  column_name,
              piv.display_sequence line_number,
        piv.input_value_id element_input_id ,
        piv.uom uom,  piv.name element_input_name
         FROM  cn_pay_element_inputs pei,
         cn_quota_pay_elements qpe,
               cn_payruns  p,
               cn_objects tab,
         cn_objects col,
         pay_element_types_f pet,
         pay_input_values_f piv
     WHERE  qpe.pay_element_type_id =  p_element_type_id
       AND  qpe.quota_id      = decode(p_incentive_type_code,
               'PMTPLN_REC' , -1001,
               p_quota_id)
       AND   qpe.status       =  p_status
       AND   p.payrun_id      =  p_payrun_id
       AND   p.pay_date             BETWEEN  qpe.start_date AND qpe.end_date
       AND  pet.input_currency_code  = p_currency_code
       AND  qpe.pay_element_type_id  = pet.element_type_id
       AND  qpe.start_date           >= pet.effective_start_date
       AND  qpe.end_date             <= pet.effective_end_date
       AND  qpe.quota_pay_element_id = pei.quota_pay_element_id
       AND  trunc(pet.effective_start_date) = trunc(piv.effective_start_date)
       AND  trunc(pet.effective_end_date)   = trunc(piv.effective_end_date)
       AND  pei.element_input_id = piv.input_value_id
       AND   tab.object_id         = pei.tab_object_id
       AND  col.object_id            = pei.col_object_id
       AND  col.table_id             = pei.tab_object_id
       AND  p.org_id    =   tab.org_id
--       AND  p.org_id    =   col.org_id
     UNION
     SELECT null  table_name ,
      null  column_name,
            piv.display_sequence line_number,
      piv.input_value_id element_input_id,
      piv.uom uom,  piv.name element_input_name
      FROM
          pay_input_values_f  piv,
          pay_element_types_f pet,
          cn_quota_pay_elements qpe,
          cn_payruns p
     WHERE  qpe.pay_element_type_id         =  p_element_type_id
       AND  qpe.quota_id      = decode(p_incentive_type_code,
               'PMTPLN_REC' , -1001,
               p_quota_id)
       AND  qpe.status                =  p_status
       AND  p.payrun_id                     =  p_payrun_id
       AND  p.pay_date    BETWEEN qpe.start_date AND qpe.end_Date
       AND  pet.input_currency_code         = p_currency_code
       AND  qpe.pay_element_type_id         = pet.element_type_id
       AND  qpe.start_date                 >= pet.effective_start_date
       AND  qpe.end_date                   <= pet.effective_end_date
       AND  trunc(pet.effective_start_date) = trunc(piv.effective_start_date)
       AND  trunc(pet.effective_end_date)   = trunc(piv.effective_end_date)
       AND  pet.element_type_id =  piv.element_type_id
       AND  not exists ( select 1 from cn_pay_element_inputs cpei
                          WHERE cpei.quota_pay_element_id = qpe.quota_pay_element_id
                            AND qpe.pay_element_type_id = piv.element_type_id
                            AND cpei.element_input_id = piv.input_value_id )
    ORDER  by  line_number, element_input_name ;


    Cursor get_element_name ( p_element_type_id IN NUMBER ) IS
     Select element_name
       from pay_element_types_f
     where element_type_id = p_element_type_id ;

    --
    -- Cursor
    --
     TYPE  rc IS ref cursor;
     main_cursor rc;

     -- Default where clause and from Clause

     --Modified by Sundar Venkat for bug fix 2660893
     -- AC 04/09/03 2892822 : need to join with p_Incentive_type_code
     l_where        VARCHAR2(2000) :=
         '     CN_PAYRUNS.PAYRUN_ID = :B1   '
       ||' AND CN_SALESREPS.SALESREP_ID = :B2  '
       ||' AND CN_PAYRUNS.ORG_ID    =   CN_SALESREPS.ORG_ID '
       ||' AND CN_PAYMENT_TRANSACTIONS.QUOTA_ID = :B3'
       ||' AND CN_PAYMENT_TRANSACTIONS.PAYRUN_ID = CN_PAYRUNS.PAYRUN_ID'
       ||' AND CN_PAYMENT_TRANSACTIONS.INCENTIVE_TYPE_CODE = :B4 '
       ||' AND CN_PAYMENT_TRANSACTIONS.CREDITED_SALESREP_ID = CN_SALESREPS.SALESREP_ID'
       ||' AND CN_PAYMENT_TRANSACTIONS.PAY_ELEMENT_TYPE_ID IS NOT NULL';

     l_from            VARCHAR2(2000) := ' CN_PAYRUNS, CN_SALESREPS, CN_PAYMENT_TRANSACTIONS ';

     l_select        VARCHAR2(32000) ;

     -- Total Input Values Defined
     l_count           NUMBER := 0;



     -- Total 15 Param is allowed
     l_param1          VARCHAR2(2000);
     l_param2          VARCHAR2(2000);
     l_param3          VARCHAR2(2000);
     l_param4          VARCHAR2(2000);
     l_param5          VARCHAR2(2000);
     l_param6          VARCHAR2(2000);
     l_param7          VARCHAR2(2000);
     l_param8          VARCHAR2(2000);
     l_param9          VARCHAR2(2000);
     l_param10         VARCHAR2(2000);
     l_param11         VARCHAR2(2000);
     l_param12         VARCHAR2(2000);
     l_param13         VARCHAR2(2000);
     l_param14         VARCHAR2(2000);
     l_param15         VARCHAR2(2000);

     l_batch_id              NUMBER;
     l_object_version_number NUMBER;
     l_batch_line_id         NUMBER;
     l_element_name    pay_element_types_f.element_name%type;

     l_mask    varchar2(100) ;

     CURSOR cn_repositories_cur IS
  SELECT glsob.set_of_books_id set_of_books_id,
               glsob.currency_code currency_code
   FROM gl_sets_of_books glsob,
          cn_repositories cnr,
          cn_payruns cnp
    WHERE  cnr.set_of_books_id             = glsob.set_of_books_id
      AND cnr.org_id = cnp.org_id
      AND cnp.payrun_id =   p_payrun_id;

     l_repositories_rec cn_repositories_cur%ROWTYPE;

     --Bug 3995491(11.5.8 bug 3925653, 11.5.10 bug 3995477) by jjhuang on 11/5/04.
     l_action_if_exists hr_lookups.lookup_code%TYPE;

  BEGIN

    --
    -- Set the status
    --
    x_loading_status := p_loading_status;
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    --
    -- get Payruns detail, org_id, period_id, pay_date, name
    --
    l_batch_id := x_batch_id;

    --Bug 3995491(11.5.8 bug 3925653, 11.5.10 bug 3995477) by jjhuang on 11/5/04.
    l_action_if_exists := fnd_profile.value('CN_PAYROLL_ACTION_IF_ENTRY_EXISTS');

    --
    -- get cn_repositories
    --

    OPEN cn_repositories_cur;
    FETCH cn_repositories_cur INTO l_repositories_rec;
    CLOSE cn_repositories_cur;

    --
    -- Get currency Mask
    --

    l_mask :=  fnd_currency.get_format_mask((Nvl(l_repositories_rec.currency_code,'USD')),20);

    --
    -- get Payruns detail, org_id, period_id, pay_date, name
    --

    open get_payruns;
    fetch get_payruns into l_payrun_rec;
    close get_payruns;

    --Bug 3314913 by jjhuang on 12/15/03. In length(cn_payruns.name)=80, but the length for integration only needs 30.
    l_payrun_rec.name := substr(l_payrun_rec.name, 1, 30);

    --
    -- get assignment , assignment_id, bussiness group id, status
    --
    open get_assign_id(l_payrun_rec.org_id);
    fetch get_assign_id into l_assignment_rec;
    close get_assign_id;

    IF l_assignment_rec.source_business_grp_id is not null THEN

    --
    -- Get the inputs, column name, column_value, table_name
    --

    --
    -- Get the Element Name
    --

   open get_element_name ( p_element_type_id);
   fetch get_element_name into l_element_name;
   close get_element_name;



    FOR tab_columns IN pay_element_inputs( nvl(l_assignment_rec.status,'A'),
             l_repositories_rec.currency_code)
      LOOP

   -- AC 04/09/2003 2892822 : should not use p_amount, cause p_amount is
   -- sum of all pmt trx with same quota_id,srp_id,incentive_type,
   -- pay_element_type_id but the dynamic sql statement here cannot do a
   -- group by so should use original payment_amount

       IF tab_columns.table_name = 'CN_PAYMENT_TRANSACTIONS' and
   tab_columns.column_name = 'PAYMENT_AMOUNT' THEN
             l_select := l_select || tab_columns.table_name
         ||'.'||tab_columns.column_name -- nvl(p_amount,0)
         || ' C_'||l_count|| ',';
   --Commented by Sundar Venkat for bug fix 2660893
         --IF l_flag_payment_transactions = 'N' THEN
         --   l_from := l_from || ', ' || tab_columns.table_name ;
         --    l_where := l_where || ' AND CN_PAYMENT_TRANSACTIONS.PAYRUN_ID = CN_PAYRUNS.PAYRUN_ID ' ;
   --   l_flag_payment_transactions := 'Y';
   --END IF ;

       ELSIF tab_columns.table_name iS NOT NULL THEN

    l_select := l_select || tab_columns.table_name
                               ||'.'||tab_columns.column_name
                               || ' C_'||l_count|| ',';
         --Commented by Sundar Venkat for bug fix 2660893
         -- IF l_flag_payment_transactions = 'N' AND tab_columns.table_name = 'CN_PAYMENT_TRANSACTIONS' THEN
         --    l_from := l_from || ', ' || tab_columns.table_name ;
         --    l_where := l_where || ' AND CN_PAYMENT_TRANSACTIONS.PAYRUN_ID= CN_PAYRUNS.PAYRUN_ID ' ;
   --    l_flag_payment_transactions := 'Y';
   -- END IF ;


       ELSE
           l_select := l_select || 'NULL'
                               || ' C_'||l_count|| ',';
       END IF;
          l_count  := pay_element_inputs%ROWCOUNT;
    END LOOP;

    --
    -- remove the extra comma
    --
    l_select := substr(l_select, 1, length(l_select)-1);

    --
    -- check if the l_count
    --
    IF l_count < 15 THEN
       FOR i in 1..(15 - l_count) LOOP
         if l_select is null then
            l_select := l_select ||  ' NULL ' ;
         else
            l_select := l_select || ',' || ' NULL ' ;
         end if;
       END LOOP;
    END IF;


    --
    -- get the where clause
    --
    l_select := ' SELECT ' || l_select
                           || ' FROM ' || l_from
                           || ' WHERE ' || l_where;

    --
    -- Processs only if there is column mapping.
    --
    IF l_count > 0
       THEN
          --Modified by Sundar Venkat for bug fix 2660893
          open  main_cursor for l_select using p_payrun_id, p_salesrep_id, p_quota_id, p_incentive_type_code ;
          loop

          fetch main_cursor into  l_param1
                                  ,l_param2
                                  ,l_param3
                                  ,l_param4
                                  ,l_param5
                                  ,l_param6
                                  ,l_param7
                                  ,l_param8
                                  ,l_param9
                                  ,l_param10
                                  ,l_param11
                                  ,l_param12
                                  ,l_param13
                                  ,l_param14
                                  ,l_param15;
          exit when main_cursor%notfound;

        -- Call the BEE Interface

        IF l_batch_id IS NULL THEN

          IF l_action_if_exists IS NULL
          THEN
               PAY_BATCH_ELEMENT_ENTRY_API.CREATE_BATCH_HEADER
                  (p_validate            => FALSE,
                  p_session_date          => l_payrun_rec.pay_date,
                  p_batch_name            => l_payrun_rec.name,
                  p_business_group_id     => l_assignment_rec.source_business_grp_id,
                  p_batch_reference       => l_payrun_rec.name,
                  p_batch_source          => 'CN',
                  p_comments              => NULL,
                  p_purge_after_transfer  => 'N',
                  p_batch_id              => l_batch_id,
                  P_OBJECT_VERSION_NUMBER => l_object_version_number );
          ELSE
             IF l_action_if_exists = 'U' THEN
                 PAY_BATCH_ELEMENT_ENTRY_API.CREATE_BATCH_HEADER
                    (p_validate            => FALSE,
                    p_session_date          => l_payrun_rec.pay_date,
                    p_batch_name            => l_payrun_rec.name,
                    p_business_group_id     => l_assignment_rec.source_business_grp_id,
                    p_action_if_exists      => l_action_if_exists,
                    p_batch_reference       => l_payrun_rec.name,
                    p_batch_source          => 'CN',
                    p_comments              => NULL,
                    p_date_effective_changes => 'C',
                    p_purge_after_transfer  => 'N',
                    p_batch_id              => l_batch_id,
                    P_OBJECT_VERSION_NUMBER => l_object_version_number );
             ELSE
                 PAY_BATCH_ELEMENT_ENTRY_API.CREATE_BATCH_HEADER
                    (p_validate            => FALSE,
                    p_session_date          => l_payrun_rec.pay_date,
                    p_batch_name            => l_payrun_rec.name,
                    p_business_group_id     => l_assignment_rec.source_business_grp_id,
                    p_action_if_exists      => l_action_if_exists,
                    p_batch_reference       => l_payrun_rec.name,
                    p_batch_source          => 'CN',
                    p_comments              => NULL,
                    p_purge_after_transfer  => 'N',
                    p_batch_id              => l_batch_id,
                    P_OBJECT_VERSION_NUMBER => l_object_version_number );
             END IF ;
          END IF;


           IF l_batch_id IS NULL  THEN
             --Error condition
             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
              THEN
              fnd_message.set_name('CN', 'CN_BATCH_HEADER_FAILED');
              fnd_msg_pub.add;
             END IF;

             x_loading_status := 'CN_BATCH_HEADER_FAILED';
             RAISE FND_API.G_EXC_ERROR;

          END IF;
        END IF;

        PAY_BATCH_ELEMENT_ENTRY_API.CREATE_BATCH_LINE
          (p_validate              => FALSE,
           p_session_date          => l_payrun_rec.pay_date,
           p_batch_id              => l_batch_id,
           p_batch_line_status     => 'U',
           p_assignment_id         => l_assignment_rec.assignment_id,
           p_assignment_number     => l_assignment_rec.assignment_number,
           p_element_type_id       => p_element_type_id,
           p_element_name          => l_element_name,
           p_effective_date        => l_payrun_rec.pay_date,
           p_entry_type            => 'E',
           p_value_1               => l_param1,
           p_value_2               => l_param2,
           p_value_3               => l_param3,
           p_value_4               => l_param4,
           p_value_5               => l_param5,
           p_value_6               => l_param6,
           p_value_7               => l_param7,
           p_value_8               => l_param8,
           p_value_9               => l_param9,
           p_value_10              => l_param10,
           p_value_11              => l_param11,
           p_value_12              => l_param12,
           p_value_13              => l_param13,
           p_value_14              => l_param14,
           p_value_15              => l_param15,
           p_batch_line_id         => l_batch_line_id,
           p_object_version_number => l_object_version_number);


           IF  l_batch_line_id  IS NULL  THEN
             --Error condition
             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
              THEN
              fnd_message.set_name('CN', 'CN_BATCH_LINE_FAILED');
              fnd_msg_pub.add;
             END IF;

             x_loading_status := 'CN_BATCH_LINE_FAILED';
             RAISE FND_API.G_EXC_ERROR;

          END IF;

      end loop;
      close main_cursor;
     END IF;

   END IF; -- business group id is not null

   x_batch_id := l_batch_id;

   -- End of Building and Calling BEE API
   -- Standard call to get message count and if count is 1,
   -- get message info.

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;

END;
-- ===========================================================================
--   Procedure   : Build and call the BEE API
--   Description : called from pay Payrun passing the payrun id as the input
--       input parameter.
-- ===========================================================================
PROCEDURE BUILD_BEE_API
  (x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_payrun_id          IN  NUMBER,
   p_loading_status     IN  VARCHAR2,
   x_loading_status     OUT NOCOPY VARCHAR2) IS

   l_api_name  CONSTANT VARCHAR2(30) := 'Build_Bee_Api';

   --group by clause modified by Sundar Venkat for bug fix 2660893

     CURSOR payment_curs IS
  SELECT sum(nvl(pt.payment_amount,0)) payment_amount,
    pt.credited_salesrep_id,
    pt.pay_element_type_id,
    pt.quota_id,
    pt.incentive_type_code
    FROM cn_payment_transactions pt
    WHERE pt.payrun_id = p_payrun_id
    AND nvl(waive_flag,'N') = 'N'
    AND nvl(hold_flag, 'N') = 'N'
      GROUP BY  pt.quota_id,
                pt.credited_salesrep_id,
                pt.pay_element_type_id,
                pt.incentive_type_code;


   l_rec_nrec_amount  NUMBER := 0;
   x_batch_id       NUMBER := NULL;

 BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_payrun_id IS NULL THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAYRUN');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_PAYRUN';
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   FOR payment IN payment_curs  LOOP

     Build_Parse_Fetch_Call
     (x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_payrun_id      => p_payrun_id,
      p_salesrep_id    => payment.credited_salesrep_id,
      p_element_type_id=> payment.pay_element_type_id,
      p_quota_id       => payment.quota_id,
      p_incentive_type_code => payment.incentive_type_code,
      p_amount         => payment.payment_amount,
      p_loading_status => x_loading_status,
      x_loading_status => x_loading_status,
      x_batch_id       => x_batch_id);

      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;


   -- End of Building and Calling BEE API
   -- Standard call to get message count and if count is 1,
   -- get message info.

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;

END Build_BEE_Api;


FUNCTION validate_pay
  (
   p_payrun                 IN NUMBER,
   p_pay_date               IN  DATE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
   --RETURN VARCHAR2 IS
   RETURN BOOLEAN
 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_pay';
      l_quota_payelements NUMBER;
      l_num_pe_mapping NUMBER;
      l_pe_name varchar2(80);


  CURSOR get_quotas(p_payrun cn_payruns.payrun_id%TYPE) IS
	select  distinct w.quota_id,q.name
	from cn_payment_worksheets w,
	cn_quotas q,cn_salesreps cns
	where payrun_id=p_payrun
	and w.quota_id is not null
	and w.quota_id=q.quota_id
	and w.salesrep_id=cns.salesrep_id
	and w.org_id  = cns.org_id
	and cns.type='EMPLOYEE';


        CURSOR get_quota_payelements(p_quotaId NUMBER,p_pay_date DATE) IS
                    select COUNT(*) from
                    cn_quota_pay_elements
                    where quota_id = p_quotaId
                    and p_pay_date
                    between
                    START_DATE and END_DATE;

        CURSOR get_num_pe_mapping (p_quota_id NUMBER) IS
                    select COUNT(*) from
                    cn_pay_element_inputs_all cp,
                    cn_quota_pay_elements_all cq
                    WHERE
                    cp.quota_pay_element_id = cq.quota_pay_element_id
                    AND cq.quota_id =p_quota_id;




BEGIN
  x_loading_status := p_loading_status ;

 FOR quotas IN get_quotas(p_payrun)
 LOOP
   l_quota_payelements := 0;
   l_num_pe_mapping :=0;

   OPEN  get_quota_payelements(quotas.quota_id,p_pay_date);
   FETCH get_quota_payelements INTO l_quota_payelements;
   CLOSE get_quota_payelements;



      IF l_quota_payelements = 0 THEN
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_PE_PAYE_MAPPING');
         fnd_msg_pub.add;
         END IF;

        x_loading_status := 'CN_PE_PAYE_MAPPING';
      RAISE FND_API.G_EXC_ERROR;
      END IF;

   OPEN  get_num_pe_mapping(quotas.quota_id);
   FETCH get_num_pe_mapping INTO l_num_pe_mapping;
   CLOSE get_num_pe_mapping;

        IF l_num_pe_mapping = 0 THEN
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_PE_MAPPING');
        fnd_message.set_token('PE_NAME', quotas.name);
         fnd_msg_pub.add;
         END IF;

        x_loading_status := 'CN_PE_MAPPING';
      RAISE FND_API.G_EXC_ERROR;
      END IF;

 END LOOP;

   	RETURN TRUE;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN FALSE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN FALSE;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN FALSE;


END validate_pay;




-- ===========================================================================
--   Procedure   : Validate_pay_date
--   Description : This procedure is used to check if the pay_date < = start_date
--   Calls       :
-- ===========================================================================
FUNCTION validate_pay_date
  (
   p_pay_date               IN  DATE,
   p_start_date       IN  DATE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_pay_date';

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   IF p_pay_date < p_start_date
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAY_DATE');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_DATE';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END validate_pay_date;



-- ===========================================================================
--
--   Procedure   : Validate_payrun_status
--   Description : This procedure is used to check if the pay status is null or unpaid
--   Calls       :
--
-- ===========================================================================
FUNCTION validate_payrun_status
  (
   p_status                 IN  cn_payruns.status%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_status';

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;


   IF p_status <> '' OR p_status <> 'UNPAID'
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAYRUN_STATUS');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAYRUN_STATUS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END validate_payrun_status;
-- ===========================================================================
--
--   Procedure   : Validate_name_unique
--   Description : This procedure is used to check if the name of the pay run is unique
--   Calls       :
--
-- ===========================================================================
FUNCTION validate_name_unique
  (
   p_name                   IN  cn_payruns.name%TYPE,
   p_org_id                 IN cn_payruns.org_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_name_unique';

      CURSOR get_count IS
   SELECT COUNT(1)
     FROM cn_payruns
     WHERE name = p_name
       AND org_id=p_org_id;

      l_count  NUMBER;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   OPEN get_count;
   FETCH get_count INTO l_count;
   CLOSE get_count;

   IF l_count <> 0 THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_NUNIQUE_PAYRUN_NAME');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_NUNIQUE_PAYRUN_NAME';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END validate_name_unique;



-- ===========================================================================
--
--   Procedure   : Validate_pay_group
--   Description : This procedure is used to validate if the pay group exists
--   Calls       :
--
-- ===========================================================================

FUNCTION validate_pay_group
  (
   p_pay_group_id           IN  cn_payruns.pay_group_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_pay_group';

      CURSOR get_count IS
   SELECT COUNT(1)
     FROM cn_pay_groups
     WHERE pay_group_id = p_pay_group_id;

      l_count  NUMBER;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   OPEN get_count;
   FETCH get_count INTO l_count;
   CLOSE get_count;

   IF l_count = 0 THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAY_GROUP');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_GROUP';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END validate_pay_group;


-- ===========================================================================
--
--   Procedure   : Validate_pay_period
--   Description : This procedure is used to validate if the pay period exists
--   Calls       :
--
-- ===========================================================================

FUNCTION validate_pay_period
  (
   p_pay_group_id           IN  cn_payruns.pay_group_id%TYPE,
   p_pay_period_id          IN  cn_payruns.pay_period_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_pay_period';

      CURSOR get_count IS
   SELECT COUNT(1)
     FROM cn_pay_groups cnpg,
     cn_period_statuses cnps
     WHERE cnpg.pay_group_id = p_pay_group_id
     AND   cnpg.period_set_name = cnps.period_set_name
     AND   cnpg.period_type = cnps.period_type
     AND   cnps.period_id = p_pay_period_id
     AND   cnpg.org_id =  cnps.org_id;

      l_count  NUMBER;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   OPEN get_count;
   FETCH get_count INTO l_count;
   CLOSE get_count;

   IF l_count = 0 THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAY_PERIOD');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_PERIOD';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END validate_pay_period;


-- ===========================================================================
--
--   Procedure   : Check_unpaid_payrun
--   Description : This procedure is used to check if an unpaid payrun exists
--   Calls       :
--
-- ===========================================================================

FUNCTION check_unpaid_payrun
  (
   p_pay_group_id           IN  cn_payruns.pay_group_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Check_unpaid_payrun';

      CURSOR get_count IS
   SELECT COUNT(1)
     FROM cn_payruns
     WHERE pay_group_id = p_pay_group_id
     AND   status <> 'PAID';

      l_count  NUMBER;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   OPEN get_count;
   FETCH get_count INTO l_count;
   CLOSE get_count;

   IF l_count <> 0 THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
         fnd_message.set_name('CN', 'CN_UNPAID_PAYRUN_EXISTS');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_UNPAID_PAYRUN_EXISTS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END check_unpaid_payrun;

-- ===========================================================================
--
--   Procedure   : Chk_last_paid_prd
--   Description : This procedure is used to check which period got paid last
--   Calls       :
--
-- ===========================================================================

FUNCTION chk_last_paid_prd
  (
   p_pay_group_id           IN  cn_payruns.pay_group_id%TYPE,
   p_org_id                 IN  cn_payruns.org_id%TYPE,
   p_pay_period_id          IN  cn_payruns.pay_period_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Chk_last_paid_prd';

      CURSOR get_last_pay_period IS
   SELECT pay_period_id
     FROM cn_payruns
     WHERE pay_group_id = p_pay_group_id
     ORDER BY payrun_id desc ;

      CURSOR get_period_range (p_period_id IN cn_period_statuses.period_id%TYPE) IS
   SELECT start_date, end_date
     FROM cn_period_statuses
     WHERE period_id = p_period_id
       AND org_id=p_org_id;

      l_get_period_range_rec get_period_range%ROWTYPE;


      l_pay_period_id        cn_payruns.pay_period_id%TYPE;
      l_last_start_date      cn_period_statuses.start_date%TYPE;
      l_cur_start_date       cn_period_statuses.start_date%TYPE;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   OPEN get_last_pay_period;
   FETCH get_last_pay_period INTO l_pay_period_id;
   CLOSE get_last_pay_period;

   OPEN get_period_range (l_pay_period_id);
   FETCH get_period_range INTO l_get_period_range_rec;
   CLOSE get_period_range;
   l_last_start_date := l_get_period_range_rec.start_date;

   OPEN get_period_range (p_pay_period_id);
   FETCH get_period_range INTO l_get_period_range_rec;
   CLOSE get_period_range;
   l_cur_start_date := l_get_period_range_rec.start_date;


   IF l_last_start_date > l_cur_start_date THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
   fnd_message.set_name('CN', 'CN_NEWER_PAYRUN_EXISTS');
   fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_NEWER_PAYRUN_EXISTS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END chk_last_paid_prd;



-- ===========================================================================
--
--   Procedure   : populate_ap_interface
--   Description : This is used to populate the AP interface for
--                 salesreps in the specified payrun who are of
--                 type supplier contact.
--   Calls       :
--
-- ===========================================================================

FUNCTION populate_ap_interface
  (
   p_payrun_id              IN  cn_payruns.payrun_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      G_LAST_UPDATE_DATE          DATE    := sysdate;
      G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
      G_CREATION_DATE             DATE    := sysdate;
      G_CREATED_BY                NUMBER  := fnd_global.user_id;
      G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

      l_api_name  CONSTANT VARCHAR2(30) := 'populate_ap_interface';
--for Performance issues SQL ID 16120772 we had to break this sql
/*
      CURSOR get_vendors IS
   SELECT cns.salesrep_id, pvs.vendor_id supplier_id,
    pvc.vendor_site_id supplier_site_id,
    currency_code
     FROM cn_salesreps cns,
                cn_payment_worksheets cnpw,
    po_vendor_sites pvs,
                po_vendor_contacts pvc
     WHERE cnpw.payrun_id = p_payrun_id
     AND   cnpw.org_id=cns.org_id
     AND cnpw.salesrep_id = cns.salesrep_id
           AND cnpw.quota_id  IS NULL
           AND cns.source_id    = pvc.vendor_contact_id
           AND pvc.vendor_site_id = pvs.vendor_site_id
     AND cns.type = 'SUPPLIER_CONTACT';
*/





     CURSOR get_salesreps IS
   SELECT cns.salesrep_id,cns.currency_code,cns.source_id
     FROM cn_salesreps cns,
          cn_payment_worksheets cnpw
    WHERE cnpw.payrun_id = p_payrun_id
    AND   cnpw.org_id=cns.org_id
    AND   cnpw.salesrep_id = cns.salesrep_id
    AND   cnpw.quota_id  IS NULL
    AND   cns.type = 'SUPPLIER_CONTACT'
    AND   cns.source_id IS NOT NULL;


    CURSOR get_vendors(p_source_id IN cn_payment_transactions.credited_salesrep_id%TYPE) IS
    SELECT  pvs.vendor_id supplier_id,
         pvc.vendor_site_id supplier_site_id
    FROM
         po_vendor_sites pvs,
         po_vendor_contacts pvc
     WHERE
        pvc.vendor_site_id = pvs.vendor_site_id
     AND pvc.vendor_contact_id = p_source_id;




--Bug 2922190 by Julia Huang.
      CURSOR get_invoice_lines (p_salesrep_id IN cn_payment_transactions.credited_salesrep_id%TYPE) IS
   SELECT payment_transaction_id,
    ROUND(payment_amount,2) payment_amount,
    liability_ccid,
    expense_ccid
     FROM cn_payment_transactions
     WHERE payrun_id = p_payrun_id
     AND credited_salesrep_id = p_salesrep_id
     AND nvl(hold_flag,'N') = 'N';

      CURSOR get_pay_date IS
   SELECT pay_date,org_id
     FROM cn_payruns
     WHERE payrun_id = p_payrun_id;
      l_pay_date DATE;

      CURSOR get_functional_currency IS
   SELECT currency_code
     FROM gl_sets_of_books glsob,
     cn_repositories cnr,
     cn_payruns cnp
     WHERE cnr.set_of_books_id = glsob.set_of_books_id
       AND   cnr.org_id = cnp.org_id
       AND cnp.payrun_id= p_payrun_id;
      l_functional_currency gl_sets_of_books.currency_code%TYPE;

      l_lookup_type  VARCHAR2(30) := 'STANDARD';
      l_org_id  number;
      l_supplier_id po_vendor_sites.vendor_id%TYPE;
      l_supplier_site_id po_vendor_sites.vendor_site_id%TYPE;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;

   OPEN get_pay_date;
   FETCH get_pay_date INTO l_pay_date,l_org_id;
   CLOSE get_pay_date;

   IF l_pay_date IS NULL
     THEN
      l_pay_date := Sysdate;
   END IF;

   OPEN get_functional_currency;
   FETCH get_functional_currency INTO l_functional_currency;
   CLOSE get_functional_currency;

   -- Fetch all the salesrep (who are vendors) who are eligible to be paid
  -- FOR vendor IN get_vendors
  FOR salesreps IN get_salesreps
     LOOP
      OPEN get_vendors(salesreps.source_id);
      FETCH get_vendors INTO l_supplier_id,l_supplier_site_id;
      CLOSE get_vendors;

  FOR invoice IN get_invoice_lines(salesreps.salesrep_id)
    LOOP

       -- Create a record in ap_invoices_interface
       -- for each Payment Transaction line in OSC (for the invoice)

       -- Need to change the inv import later to pass the liability
       -- and expense accounts for the invoice
             --
             -- Added By Kumar Sivasankaran
             -- Refer Bug # 2160284
             --
             IF nvl(invoice.payment_amount,0)  < 0 THEN
               l_lookup_type := 'CREDIT';
             ELSE
               l_lookup_type := 'STANDARD';
             END IF;

       INSERT INTO ap_invoices_interface
         (invoice_id,
         org_id,
    invoice_num,
    invoice_date,
    vendor_id,
    vendor_site_id,
    invoice_amount,
    invoice_currency_code,
    payment_currency_code,
    source,
    accts_pay_code_combination_id,
    invoice_type_lookup_code,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN)
         VALUES
         (ap_invoices_interface_s.NEXTVAL,
         l_org_id,
    invoice.payment_transaction_id,
    l_pay_date,
    l_supplier_id,
    l_supplier_site_id,
    invoice.payment_amount,
    l_functional_currency,
    Nvl(salesreps.currency_code, l_functional_currency),
    'ORACLE_SALES_COMPENSATION',
    invoice.liability_ccid,
    l_lookup_type,
    G_CREATION_DATE,
    G_CREATED_BY,
    G_LAST_UPDATE_DATE,
    G_LAST_UPDATED_BY,
    G_LAST_UPDATE_LOGIN);

       -- Create a record in ap_invoice_lines_interface
       -- for each Payment  Transaction line in OSC (for the distribution)

       INSERT INTO ap_invoice_lines_interface
         (invoice_id,
    invoice_line_id,
    line_number,
    amount,
    dist_code_combination_id,
    line_type_lookup_code,
               org_id,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN)
         VALUES
         (ap_invoices_interface_s.CURRVAL,
    ap_invoice_lines_interface_s.NEXTVAL,
    1,
    invoice.payment_amount,
    invoice.expense_ccid,
    'ITEM',
        l_org_id,
    G_CREATION_DATE,
    G_CREATED_BY,
    G_LAST_UPDATE_DATE,
    G_LAST_UPDATED_BY,
    G_LAST_UPDATE_LOGIN);

    END LOOP;

     END LOOP;

     RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END populate_ap_interface;

-- ===========================================================================
--   Procedure   : populate_ccids
--   Description : This is used to populate the expense and liability ccids
--   Calls       :
-- ===========================================================================

FUNCTION populate_ccids
  (
   p_payrun_id              IN  cn_payruns.payrun_id%TYPE,
   p_salesrep_id            IN  cn_payment_worksheets.salesrep_id%TYPE,
   --p_start_date             IN  DATE,
   --p_end_date               IN  DATE,
   --  Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
   p_pmt_tran_id            IN cn_payment_transactions.payment_transaction_id%TYPE DEFAULT NULL,
   p_loading_status         OUT NOCOPY VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2 IS

      l_api_name  CONSTANT VARCHAR2(30) := 'populate_ccids';

 CURSOR get_vendors IS
    SELECT cns.salesrep_id
      FROM cn_salesreps cns,
      cn_payruns cnr
      WHERE
      cns.type = 'SUPPLIER_CONTACT'
      AND cns.salesrep_id = p_salesrep_id
      AND cns.org_id =cnr.org_id
      AND cnr.payrun_id=p_payrun_id;


      CURSOR get_invoice_lines IS
   SELECT payment_transaction_id
     FROM cn_payment_transactions
     WHERE payrun_id = p_payrun_id
     AND credited_salesrep_id = p_salesrep_id
     AND nvl(paid_flag, 'N') = 'N' -- is null -- Bug 2822874
     AND payee_salesrep_id = p_salesrep_id
       AND payment_transaction_id = NVL(p_pmt_tran_id, payment_transaction_id) --  Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
     AND hold_flag         = 'N' ;

           l_user fnd_user.user_name%TYPE;
     l_payables_flag             cn_repositories.payables_flag%TYPE;

BEGIN

   --
   --  Initialize API return status to success
   --
   x_loading_status := p_loading_status ;
   --chaged
   SELECT Nvl(payables_flag, 'N')
     INTO l_payables_flag
     FROM cn_repositories cr,cn_payruns cp
     where cp.payrun_id = p_payrun_id
     and cp.org_id=cr.org_id;

   IF l_payables_flag = 'Y' THEN

   SELECT user_name
     INTO l_user
     FROM fnd_user
     WHERE user_id = fnd_global.user_id;

   -- Fetch all the salesrep (who are vendors) who are eligible to be paid
   FOR vendor IN get_vendors
     LOOP

  FOR invoice IN get_invoice_lines
    LOOP
       -- inititate wf process CN Account Generator
       cn_wf_pmt_pkg.startprocess
         ( p_posting_detail_id  => invoice.payment_transaction_id,
     p_RequestorUsername    => l_user,
     p_ProcessOwner         => l_user,
     p_WorkflowProcess      => 'CNACCGEN',
     p_Item_Type          => 'CNACCGEN');

    END LOOP;

     END LOOP;

   END IF;

   RETURN fnd_api.g_false;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;

END populate_ccids;

-- ===========================================================================

-- Procedure  : Create_Payrun
-- Description: Private API to create a payrun
-- Calls      :
--
-- ===========================================================================

PROCEDURE create_payrun
  (
   p_api_version           IN NUMBER,
   p_init_msg_list    IN  VARCHAR2 ,
   p_commit       IN    VARCHAR2,
   p_validation_level IN    NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count   OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2,
   p_payrun_rec              IN  OUT NOCOPY     payrun_rec_type,
   x_loading_status OUT NOCOPY     VARCHAR2,
   x_status                OUT NOCOPY     VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Create_Payrun';
      l_api_version        CONSTANT NUMBER := 1.0;

      G_LAST_UPDATE_DATE          DATE    := sysdate;
      G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
      G_CREATION_DATE             DATE    := sysdate;
      G_CREATED_BY                NUMBER  := fnd_global.user_id;
      G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
      g_credit_type_id            CONSTANT NUMBER := -1000;

      l_has_access BOOLEAN;
    l_note_msg                 VARCHAR2(240);
  l_note_id                  NUMBER;
   l_profile_value          VARCHAR2(1);

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Create_Payrun;
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
          p_api_version ,
          l_api_name    ,
          G_PKG_NAME )
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
   x_loading_status := 'CN_INSERTED';
   --
   -- API body
    --Added for R12 payment security check begin.
    l_has_access := CN_PAYMENT_SECURITY_PVT.get_security_access(
                        CN_PAYMENT_SECURITY_PVT.g_type_payrun,
                        CN_PAYMENT_SECURITY_PVT.g_access_payrun_create);
    IF ( l_has_access = FALSE)
    THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --Added for R12 payment security check end.

   -- Mandatory parameters check for name, pay group id, pay period id, pay date

   IF ( (cn_api.chk_miss_null_char_para
   (p_char_para => p_payrun_rec.name,
    p_obj_name  =>
    cn_api.get_lkup_meaning('PAY_RUN_NAME', 'PAY_RUN_VALIDATION_TYPE'),
    p_loading_status => x_loading_status,
    x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_null_num_para
   (p_num_para => p_payrun_rec.pay_group_id,
    p_obj_name  =>
    cn_api.get_lkup_meaning('PAY_GROUP_NAME', 'PAY_RUN_VALIDATION_TYPE'),
    p_loading_status => x_loading_status,
    x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_null_num_para
   (p_num_para => p_payrun_rec.pay_period_id,
    p_obj_name  =>
    cn_api.get_lkup_meaning('PAY_PERIOD', 'PAY_RUN_VALIDATION_TYPE'),
    p_loading_status => x_loading_status,
    x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_null_date_para
   (p_date_para => p_payrun_rec.pay_date,
    p_obj_name  =>
    cn_api.get_lkup_meaning('PAY_DATE', 'PAY_RUN_VALIDATION_TYPE'),
    p_loading_status => x_loading_status,
    x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- The following validations are performed by this API
   -- pay date should be on or after the end date of the pay period
   -- status should be either null or UNPAID
   -- name should be unique
   -- check if from credit type id is valid
   -- validate if pay group exists
   -- pay_period must exist in the specified pay_group
   -- New payrun can only be created for a prd that is after the prd last paid
   -- New payrun can be created only if no unpaid exists
   -- Mandatory parameters payrun id, name, pay group id, pay period id, pay date


   -- Check if unpaid payruns exist for the current pay group

   IF check_unpaid_payrun(
        p_pay_group_id       => p_payrun_rec.pay_group_id,
--              p_org_id             => p_payrun_rec.org_id,
        p_loading_status     => x_loading_status,
        x_loading_status     => x_loading_status
        ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


   -- Check if newer payruns exist for the current pay group

   IF chk_last_paid_prd(
      p_pay_group_id       => p_payrun_rec.pay_group_id,
            p_org_id             => p_payrun_rec.org_id,
      p_pay_period_id      => p_payrun_rec.pay_period_id,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status
      ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;




   -- Validate that pay date is on or after the end date of the pay period

   IF validate_pay_date(
      p_pay_date           => p_payrun_rec.pay_date,
      p_start_date         => p_payrun_rec.pay_period_start_date,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status
      ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


   IF validate_payrun_status(
           p_status             => p_payrun_rec.status,
           p_loading_status     => x_loading_status,
           x_loading_status     => x_loading_status
           ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


   IF validate_name_unique(
         p_name        => p_payrun_rec.name,
               p_org_id            => p_payrun_rec.org_id,
         p_loading_status     => x_loading_status,
         x_loading_status     => x_loading_status
         ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


   IF validate_pay_group(
       p_pay_group_id   => p_payrun_rec.pay_group_id,
       p_loading_status      => x_loading_status,
       x_loading_status      => x_loading_status
       ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


   IF validate_pay_period(
        p_pay_group_id        => p_payrun_rec.pay_group_id,
        p_pay_period_id       => p_payrun_rec.pay_period_id,
        p_loading_status      => x_loading_status,
        x_loading_status      => x_loading_status
        ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF p_payrun_rec.incentive_type_code NOT IN ('ALL', 'COMMISSION', 'BONUS')
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
   fnd_message.set_name('CN', 'CN_INVALID_INCENTIVE_TYPE');
   fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_INCENTIVE_TYPE';
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   l_profile_value := fnd_profile.value('CN_PAY_BY_TRANSACTION');
   If (l_profile_value IS NULL OR (l_profile_value <> 'Y' AND l_profile_value <> 'N'))
   THEN

     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
   fnd_message.set_name('CN', 'CN_PAY_BY_TRANSACTION_PROFILE');
   fnd_msg_pub.add;
      END IF;
       x_loading_status := 'CN_PAY_BY_TRANSACTION_PROFILE';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   cn_payruns_pkg.insert_record(
        x_payrun_id          => p_payrun_rec.payrun_id
        ,x_name               => rtrim(ltrim(p_payrun_rec.name))
        ,x_pay_period_id      => p_payrun_rec.pay_period_id
        ,x_incentive_type_code=>  p_payrun_rec.incentive_type_code
        ,x_pay_group_id      => p_payrun_rec.pay_group_id
        ,x_pay_date           => p_payrun_rec.pay_date
        ,x_accounting_period_id=>p_payrun_rec.accounting_period_id
        ,x_batch_id       =>p_payrun_rec.batch_id
        ,x_status       =>Nvl(p_payrun_rec.status,'UNPAID')
        ,x_Created_By          =>g_created_by
        ,x_Creation_Date       =>g_creation_date
        ,x_object_version_number =>1,
        x_org_id                =>p_payrun_rec.org_id,
                x_payrun_mode           =>l_profile_value
        ) ;


   x_loading_status := 'CN_INSERTED';

   -- End of API body.
      fnd_message.set_name('CN', 'CN_PMT_CRE_NOTE');
      fnd_message.set_token('PMTBATCH_NAME', rtrim(ltrim(p_payrun_rec.name)));
      l_note_msg := fnd_message.get;

       jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_payrun_rec.payrun_id,
                            p_source_object_code      => 'CN_PAYRUNS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

     cn_payment_security_pvt.pmt_raise_event(
            p_type => 'PAYRUN',
            p_event_name  => 'create',
            p_payrun_id   => p_payrun_rec.payrun_id ) ;

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
      ROLLBACK TO Create_Payrun;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Payrun;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Payrun;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
END Create_Payrun;
-- ===========================================================================
--  Procedure   :   Update Payrun
--  Description :   This is a public procedure to update payruns
--      Called during Refresh/Freeze/Unfreeze payruns
-- ===========================================================================

PROCEDURE  Update_Payrun
   (    p_api_version     IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2,
    p_commit          IN    VARCHAR2,
    p_validation_level    IN    NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count            OUT NOCOPY   NUMBER,
    x_msg_data       OUT NOCOPY   VARCHAR2,
    p_payrun_id                     IN      cn_payruns.payrun_id%TYPE,
    p_x_obj_ver_number       IN OUT NOCOPY cn_payruns.object_version_number%TYPE,
    p_action                        IN      VARCHAR2,
    x_status               OUT NOCOPY   VARCHAR2,
  x_loading_status       OUT NOCOPY   VARCHAR2
    )
    IS

  l_api_name    CONSTANT VARCHAR2(30)  := 'Update_Payrun';
  l_api_version           CONSTANT NUMBER        := 1.0;

  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

  l_status          cn_payruns.status%TYPE;
  l_status_meaning       cn_payruns.status%TYPE;
  l_payrun_id        NUMBER;
  l_note_msg                 VARCHAR2(240);
  l_note_id                  NUMBER;




        CURSOR get_old_record IS
  SELECT status, payrun_id,name,object_version_number,
  cn_api.get_lkup_meaning(cn_payruns.status,'PAYRUN_STATUS') statusmeaning
  FROM cn_payruns
  WHERE payrun_id = p_payrun_id;
  l_old_record get_old_record%ROWTYPE;

  CURSOR get_wksht_csr IS
     SELECT payment_worksheet_id
       FROM cn_payment_worksheets
       WHERE payrun_id = p_payrun_id AND worksheet_status = 'UNPAID'
       AND quota_id IS NULL;

    l_has_access BOOLEAN;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT    Update_Payrun;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version ,
          p_api_version ,
          l_api_name    ,
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
  x_loading_status := 'CN_UPDATED';

  -- API Body
  OPEN get_old_record;
  FETCH get_old_record INTO l_old_record;
  close get_old_record;

  l_status_meaning := l_old_record.statusmeaning;
       --This part is added for OA.
      IF l_old_record.object_version_number <> p_x_obj_ver_number
      THEN
         IF (fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error))
         THEN
            fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;


  -- Step 1
  -- Procedure to check if the payrun action is valid.
  CN_PAYMENT_SECURITY_PVT.Payrun_Action
   ( p_api_version       => 1.0,
     p_init_msg_list     => fnd_api.g_true,
     p_validation_level  => fnd_api.g_valid_level_full,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,
     p_payrun_id         => p_payrun_id,
     p_action            => p_action  ,
     p_do_audit          => fnd_api.g_false
   );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
  RAISE FND_API.G_EXC_ERROR;
        END IF;

  -- Step 2
  -- Check Action Type and perform action accordingly
  -- Check for FREEZE/UNFREEZE is removed since, the status is updated
  -- in CN_PAYMENT_SECURITY_PVT.Payrun_Action

  IF p_action = 'REFRESH' THEN


   --Bug fix 2502453

    Refresh_Payrun
    ( p_api_version     => 1.0,
      p_init_msg_list     => fnd_api.g_true,
      p_commit            => fnd_api.g_false,
    p_validation_level  => fnd_api.g_valid_level_full,
    p_payrun_id         => p_payrun_id,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    x_status            => x_status,
    x_loading_status    => x_loading_status
    );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
  RAISE FND_API.G_EXC_ERROR;
        END IF;


   ELSIF p_action in ('FREEZE','UNFREEZE')  THEN
     IF (p_action = 'FREEZE') THEN

        FOR l_wksht_rec IN get_wksht_csr loop
     -- save image
     cn_payment_worksheet_pvt.set_ced_and_bb
       ( p_api_version     => 1.0,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data  => x_msg_data,
         p_worksheet_id    => l_wksht_rec.payment_worksheet_id
         );
     IF  x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
        END LOOP;
     END IF;

     -- Bug 3391231: ACHUNG 01/21/04
     -- move the audit after set_ced_and_bb.Otherwise
     -- record won't be created since set_ced_and_bb need payrun
     -- status = 'UNPAID'
     CN_PAYMENT_SECURITY_PVT.Payrun_Audit
       (p_payrun_id => p_payrun_id,
        p_action => p_action,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data);

     IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  OPEN get_old_record;
  FETCH get_old_record INTO l_old_record;
  close get_old_record;

  IF p_action <> 'REFRESH'  THEN
      fnd_message.set_name('CN', 'CN_PMT_UPD_NOTE');
      fnd_message.set_token('NEW', l_old_record.statusmeaning);
      fnd_message.set_token('OLD', l_status_meaning);
      l_note_msg := fnd_message.get;
      ELSE
      fnd_message.set_name('CN', 'CN_PMT_REF_NOTE');
      fnd_message.set_token('PMTBATCH_NAME', l_old_record.name);
      l_note_msg := fnd_message.get;
    END IF;
    jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_payrun_id,
                            p_source_object_code      => 'CN_PAYRUNS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
  COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO Update_Payrun;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Update_Payrun;
  x_loading_status := 'UNEXPECTED_ERR';
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data   ,
  p_encoded => FND_API.G_FALSE
  );
  WHEN OTHERS THEN
  ROLLBACK TO Update_Payrun;
  x_loading_status := 'UNEXPECTED_ERR';
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
  FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );

END update_payrun;
-- ===========================================================================
--  Procedure Name : Delete Payrun
--
-- ===========================================================================

PROCEDURE  Delete_Payrun
  (    p_api_version      IN  NUMBER,
       p_init_msg_list            IN  VARCHAR2,
       p_commit           IN    VARCHAR2,
       p_validation_level   IN    NUMBER,
       x_return_status         OUT NOCOPY   VARCHAR2,
       x_msg_count             OUT NOCOPY   NUMBER,
       x_msg_data      OUT NOCOPY   VARCHAR2,
       p_payrun_id                IN      cn_payruns.payrun_id%TYPE,
       p_validation_only          IN       VARCHAR2,
       x_status             OUT NOCOPY  VARCHAR2,
       x_loading_status      OUT NOCOPY   VARCHAR2
       )  IS

    l_api_name    CONSTANT VARCHAR2(30)
      := 'Delete_Payrun';
    l_api_version             CONSTANT NUMBER := 1.0;


    CURSOR get_old_record IS
       SELECT status, payrun_id,name,org_id
         FROM cn_payruns
         WHERE payrun_id = p_payrun_id;
    l_old_record get_old_record%ROWTYPE;

    CURSOR get_conc_request(l_pay_run_name varchar2) IS
      select distinct request_id
       from fnd_concurrent_requests
       where oracle_id = 900 and request_date >= (sysdate -1)
       and status_code not in ('C', 'E') and argument_text = l_pay_run_name;
    l_request get_conc_request%ROWTYPE;

      CURSOR get_worksheets IS
        SELECT payment_worksheet_id,object_version_number
          FROM cn_payment_worksheets
         WHERE payrun_id = p_payrun_id
         AND quota_id is null;

    G_LAST_UPDATE_DATE          DATE    := sysdate;
    G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
    G_CREATION_DATE             DATE    := sysdate;
    G_CREATED_BY                NUMBER  := fnd_global.user_id;
    G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
    g_credit_type_id            CONSTANT NUMBER := -1000;

      l_has_access BOOLEAN;
      l_note_msg                 VARCHAR2(240);
  l_note_id                  NUMBER;
    l_org_id        NUMBER := -999;
  l_pmtbatch_name VARCHAR2(80);
    l_request_id        NUMBER := -999;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT    Delete_Payrun;
  --
  -- Standard call to check for call compatibility.
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version ,
          p_api_version ,
          l_api_name    ,
          G_PKG_NAME )
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
  x_loading_status := 'CN_DELETED';
  --
  -- API Body
  --


  OPEN get_old_record;
  FETCH get_old_record INTO l_old_record;
  IF get_old_record%rowcount = 0 THEN

  --Error condition
  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
   fnd_message.set_name('CN', 'CN_PAYRUN_DOES_NOT_EXIST');
   fnd_msg_pub.add;
  END IF;

  x_loading_status := 'CN_PAYRUN_DOES_NOT_EXIST';
  RAISE FND_API.G_EXC_ERROR;

  END IF;
  CLOSE get_old_record;

    l_pmtbatch_name := l_old_record.NAME;
  l_org_id:=l_old_record.org_id;

  OPEN get_conc_request(l_pmtbatch_name);
  FETCH get_conc_request INTO l_request;
  IF get_conc_request%rowcount > 0 THEN
   l_request_id := l_request.request_id;

  --Error condition
  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
   fnd_message.set_name('CN', 'CN_CONC_CREATE_WKSHEET_PENDING');
   fnd_message.set_token ('REQUESTID', l_request_id);
   fnd_msg_pub.add;
  END IF;

  x_loading_status := 'CN_CONC_CREATE_WKSHEET_PENDING';
  RAISE FND_API.G_EXC_ERROR;

  END IF;
  CLOSE get_conc_request;

  IF l_old_record.status IN ('PAID', 'RETURNED_FUNDS', 'PAID_WITH_RETURNS')
  THEN
  --Error condition
  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
  THEN
   fnd_message.set_name('CN', 'CN_PAYRUN_PAID');
   fnd_msg_pub.add;
  END IF;

  x_loading_status := 'CN_PAYRUN_PAID';
  RAISE FND_API.G_EXC_ERROR;

  END IF;

       -- Section included by Sundar Venkat on 07 Mar 2002
       -- Procedure to check if the payrun action is valid.
    CN_PAYMENT_SECURITY_PVT.Payrun_Action
     ( p_api_version       => 1.0,
       p_init_msg_list     => fnd_api.g_true,
       p_validation_level  => fnd_api.g_valid_level_full,
       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,
       p_payrun_id         => p_payrun_id,
       p_action            => 'REMOVE'
   );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
       RAISE FND_API.G_EXC_ERROR;
  END IF;



    FOR worksheets in get_worksheets
    LOOP

      cn_payment_worksheet_pvt.delete_worksheet(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_commit           => fnd_api.g_false,
        p_validation_level => p_validation_level,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_worksheet_id     => worksheets.payment_worksheet_id,
        p_validation_only  => p_validation_only, --R12
        x_status           => x_status,
      x_loading_status     => x_loading_status,
        p_ovn                 =>worksheets.object_version_number);

  IF x_return_status <> FND_API.g_ret_sts_success THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

    END LOOP;

  IF  p_validation_only <> 'Y' THEN
  cn_payruns_pkg.delete_record
  (x_payrun_id          => p_payrun_id) ;

  x_loading_status := 'CN_DELETED';

  -- End of API body.
  -- Standard check of p_commit.
    IF (l_org_id <> -999) THEN
  fnd_message.set_name ('CN', 'CN_PMT_DEL_NOTE');
      fnd_message.set_token ('PMTBATCH_NAME', l_pmtbatch_name);
      l_note_msg := fnd_message.get;
      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_org_id,
                            p_source_object_code      => 'CN_REPOSITORIES',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id    -- returned
                           );
     END IF;
    END IF;

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
  ROLLBACK TO Delete_Payrun;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Delete_Payrun;
  x_loading_status := 'UNEXPECTED_ERR';
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data   ,
  p_encoded => FND_API.G_FALSE
  );
  WHEN OTHERS THEN
  ROLLBACK TO Delete_Payrun;
  x_loading_status := 'UNEXPECTED_ERR';
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
  FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get
  (
  p_count   =>  x_msg_count ,
  p_data    =>  x_msg_data  ,
  p_encoded => FND_API.G_FALSE
  );

END Delete_Payrun;

-- ===========================================================================
-- Procedure : Pay_payrun_Approve_Wksht
-- Description: Approve all whskt before pay a payrun
-- ===========================================================================

PROCEDURE  Pay_Payrun_Approve_Wksht
  (p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data   OUT NOCOPY VARCHAR2,
   p_payrun_id          IN  cn_payruns.payrun_id%TYPE )
  IS

     l_api_name   CONSTANT VARCHAR2(30)  := 'Pay_Payrun_Approve_Wksht';
     l_api_version      CONSTANT NUMBER        := 1.0;

     CURSOR get_unpaid_wksht IS
  SELECT payment_worksheet_id, salesrep_id
    FROM cn_payment_worksheets
    WHERE payrun_id = p_payrun_id AND worksheet_status = 'UNPAID'
    AND quota_id IS NULL ;

     CURSOR get_unapprove_wksht IS
  SELECT payment_worksheet_id, salesrep_id
    FROM cn_payment_worksheets
    WHERE payrun_id = p_payrun_id AND worksheet_status <> 'APPROVED'
    AND quota_id IS NULL;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Pay_Payrun_Approve_Wksht;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- API body
   --

   -- Lock any unpaid worksheets so cn_worksheet_qg_dtls and wksht bb cols
   -- will get populate
   FOR unpaid_rec IN get_unpaid_wksht LOOP
      -- save current image if LOCK worksheet
      cn_payment_worksheet_pvt.set_ced_and_bb ( p_api_version     => 1.0,
                                                x_return_status   => x_return_status,
                                                x_msg_count       => x_msg_count,
                                                x_msg_data        => x_msg_data,
                                                p_worksheet_id    => unpaid_rec.payment_worksheet_id
                                                );

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- validate lock and audit worksheet
      cn_payment_security_pvt.worksheet_action(p_api_version           => 1.0,
                                               p_init_msg_list         => fnd_api.g_false,
                                               p_commit                => 'F',
                                               p_validation_level      => p_validation_level,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data,
                                               p_worksheet_id          => unpaid_rec.payment_worksheet_id,
                                               p_action                => 'LOCK',
                                               p_do_audit              => fnd_api.g_true
                                              );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Approve all wksht
   FOR unapprove_rec IN get_unapprove_wksht LOOP
      -- validate
      cn_payment_security_pvt.worksheet_action(p_api_version           => 1.0,
                                               p_init_msg_list         => fnd_api.g_false,
                                               p_commit                => 'F',
                                               p_validation_level      => p_validation_level,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data,
                                               p_worksheet_id          => unapprove_rec.payment_worksheet_id,
                                               p_action                => 'APPROVE',
                                               p_do_audit              => fnd_api.g_false
                                              );

      -- set wksht audit
      CN_PAYMENT_SECURITY_PVT.Worksheet_Audit
                                              (p_worksheet_id => unapprove_rec.payment_worksheet_id,
                                               p_payrun_id => p_payrun_id,
                                               p_salesrep_id => unapprove_rec.salesrep_id,
                                               p_action => 'APPROVE',
                                               p_do_approval_flow => FND_API.G_FALSE,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data);

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- End of API body

   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Pay_Payrun_Approve_Wksht;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Pay_Payrun_Approve_Wksht;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data   ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN OTHERS THEN
      ROLLBACK TO Pay_Payrun_Approve_Wksht;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
END Pay_Payrun_Approve_Wksht;

-- ===========================================================================
-- Procedure : Pay_payrun
-- Description: To pay a payrun
--              Update the subledger
-- Modified logic to achieve the Payment Plan Amount.
-- Kumar Sivasankaran 11/12/2001
-- Matt Blum          05/02/2002
-- ===========================================================================

PROCEDURE  Pay_Payrun
  (    p_api_version      IN  NUMBER,
       p_init_msg_list        IN  VARCHAR2,
       p_commit             IN  VARCHAR2,
       p_validation_level   IN  NUMBER,
       x_return_status        OUT NOCOPY VARCHAR2,
       x_msg_count             OUT NOCOPY NUMBER,
       x_msg_data           OUT NOCOPY VARCHAR2,
       p_payrun_id              IN  cn_payruns.payrun_id%TYPE,
       p_x_obj_ver_number       IN OUT NOCOPY cn_payruns.object_version_number%TYPE,
       x_status              OUT NOCOPY VARCHAR2,
       x_loading_status      OUT NOCOPY VARCHAR2
       ) IS

       l_api_name   CONSTANT VARCHAR2(30)  := 'Pay_Payrun';
       l_api_version            CONSTANT NUMBER        := 1.0;

       -- for balances
       l_ctrl_pmt_amount     NUMBER := 0;
--       l_hold_pmt            NUMBER := 0;
       l_pmt_amount_rec      NUMBER := 0;
       l_pmt_amount_nrec     NUMBER := 0;
       l_recovery            NUMBER := 0;
       l_tot_recovery        NUMBER := 0;
       l_waive_recovery      NUMBER := 0;
       l_pmt_amount_calc     NUMBER := 0;
       l_tot_pmt_amount_calc NUMBER := 0;
       l_adj_amount          NUMBER := 0;
       l_rec_amt             NUMBER := 0;
       l_quota_id            NUMBER;

       -- general stuff
       l_posting_batch_id    NUMBER;
       l_batch_name          VARCHAR2(30);
       l_credit_type_id      NUMBER := -1000;

       -- for payroll integration
       l_element_type_id     NUMBER;
       l_payables_flag       cn_repositories.payables_flag%TYPE;
       l_payroll_flag        cn_repositories.payroll_flag%TYPE;
       l_payables_ccid_level cn_repositories.payables_ccid_level%TYPE;

       l_pmt_trx_rec         cn_pmt_trans_pkg.pmt_trans_rec_type;
       l_batch_rec           cn_prepostbatches.posting_batch_rec_type;

       -- for API calls
       l_loading_status      VARCHAR2(30);
       l_rowid               VARCHAR2(30);

       l_srp_prd_rec cn_srp_periods_pvt.delta_srp_period_rec_type
         := cn_srp_periods_pvt.g_miss_delta_srp_period_rec;
       l_note_msg                 VARCHAR2(240);
     l_note_id                  NUMBER;
     l_status_meaning       cn_payruns.status%TYPE;

       CURSOR get_payrun IS
       SELECT pay_period_id, pay_date, accounting_period_id, org_id
       ,name, cn_api.get_lkup_meaning(cn_payruns.status,'PAYRUN_STATUS') statusmeaning
         FROM cn_payruns
        WHERE payrun_id = p_payrun_id;

       l_payrun_rec          get_payrun%ROWTYPE;

       CURSOR get_salesreps_in_payrun(p_org_id cn_payruns.org_id%TYPE) IS
       SELECT distinct salesrep_id
         FROM cn_payment_worksheets
        WHERE payrun_id = p_payrun_id
        --R12
        AND org_id = p_org_id;

       CURSOR get_worksheet_data_for_pe (p_salesrep_id NUMBER, p_org_id cn_payruns.org_id%TYPE)IS
       SELECT salesrep_id, quota_id, credit_type_id,
              pmt_amount_calc, pmt_amount_adj, pmt_amount_adj_rec,
              pmt_amount_adj_nrec, pmt_amount_recovery
         FROM cn_payment_worksheets
      WHERE payrun_id = p_payrun_id
          AND salesrep_id = p_salesrep_id
   AND quota_id is not null;



       CURSOR get_srp_period(p_salesrep_id NUMBER,
                             p_period_id   NUMBER,
                             p_quota_id    NUMBER,
                             p_org_id cn_payruns.org_id%TYPE) IS
       SELECT srp_period_id
         FROM cn_srp_periods
        WHERE salesrep_id          = p_salesrep_id
          AND credit_type_id       = l_credit_type_id
          AND period_id            = p_period_id
          AND (quota_id            = p_quota_id
              OR
              (p_quota_id IS NULL AND quota_id IS NULL))
          --R12
          AND org_id = p_org_id
        AND ROWNUM < 2 ; -- Bug 2819874

       -- for payroll integration
       CURSOR get_apps(p_org_id cn_payruns.org_id%TYPE) IS
       SELECT payables_flag, payroll_flag, payables_ccid_level
         FROM cn_repositories
         --R12
         WHERE org_id = p_org_id;



       -- for wkshts with null quota ID - get from transactions
       CURSOR get_control_pmt(p_salesrep_id NUMBER,
                              p_quota_id    NUMBER,
                              p_org_id cn_payruns.org_id%TYPE) IS
       SELECT nvl(sum(nvl(payment_amount,0) - nvl(amount,0)),0) control_payment
         FROM cn_payment_transactions
        WHERE payrun_id            = p_payrun_id
          AND credited_salesrep_id = p_salesrep_id
          AND credit_type_id       = l_credit_type_id
          AND (quota_id             = p_quota_id
               OR
              (p_quota_id IS NULL AND quota_id IS NULL))
          AND incentive_type_code <> 'PMTPLN_REC'
          AND nvl(hold_flag, 'N')  = 'N';

       CURSOR get_hold_pmt(p_salesrep_id NUMBER,
                           p_quota_id    NUMBER) IS
       SELECT nvl(sum(nvl(amount,0)),0) hold_payment
         FROM cn_payment_transactions
        WHERE payrun_id            = p_payrun_id
          AND credited_salesrep_id = p_salesrep_id
          AND credit_type_id       = l_credit_type_id
          AND (quota_id             = p_quota_id
              OR
              (p_quota_id IS NULL AND quota_id IS NULL))
          AND incentive_type_code <> 'PMTPLN_REC'
    AND nvl(hold_flag, 'N')  = 'Y';

      -- Bug 2795606 : use amount not pmt_amt since get_cp will handle adj amt

       CURSOR get_man_pay_adj(p_salesrep_id NUMBER,
                           p_quota_id    NUMBER,
                           p_org_id cn_payruns.org_id%TYPE) IS
       SELECT nvl(sum(nvl(amount,0)),0) man_pay_adj, recoverable_flag
         FROM cn_payment_transactions
        WHERE payrun_id            = p_payrun_id
          AND credited_salesrep_id = p_salesrep_id
          AND credit_type_id       = l_credit_type_id
          AND quota_id             = p_quota_id
          AND incentive_type_code  = 'MANUAL_PAY_ADJ'
     GROUP BY recoverable_flag;

       CURSOR get_payment_details(p_salesrep_id NUMBER,
                                  p_quota_id    NUMBER,
                                  p_org_id cn_payruns.org_id%TYPE) IS
       SELECT nvl(pmt_amount_calc,0),
              nvl(pmt_amount_adj_rec,0),
              nvl(pmt_amount_adj_nrec,0),
              -nvl(pmt_amount_recovery,0)
         FROM cn_payment_worksheets
        WHERE payrun_id            = p_payrun_id
          AND salesrep_id          = p_salesrep_id
          AND credit_type_id       = l_credit_type_id
          AND (quota_id             = p_quota_id
              OR
              (p_quota_id IS NULL AND quota_id IS NULL));

       CURSOR get_waive_rec(p_salesrep_id NUMBER,
                      p_quota_id    NUMBER,
                            p_org_id cn_payruns.org_id%TYPE) IS
       SELECT -nvl(sum(nvl(payment_amount,0)),0)
         FROM cn_payment_transactions
      WHERE payrun_id            = p_payrun_id
        AND credited_salesrep_id = p_salesrep_id
        AND credit_type_id       = l_credit_type_id
        AND incentive_type_code  = 'PMTPLN_REC'
        AND nvl(hold_flag, 'N')  = 'N'
        AND waive_flag           = 'Y'
        AND (quota_id             = p_quota_id
              OR
              (p_quota_id IS NULL AND quota_id IS NULL))
          --R12
          AND org_id = p_org_id;

       -- get carry over srp_periods record
       CURSOR carry_over_srp_period(c_salesrep_id NUMBER,
            c_period_id NUMBER,
                    p_org_id cn_payruns.org_id%TYPE) IS
        SELECT sprd.srp_period_id
      FROM cn_srp_periods sprd
      WHERE
      sprd.salesrep_id = c_salesrep_id
      AND sprd.period_id = c_period_id
      AND sprd.quota_id = -1000
      AND sprd.credit_type_id = -1000
        --R12
        AND org_id = p_org_id;

       -- Get sync_accum records. Bug 3151860
       CURSOR sync_accum(c_salesrep_id NUMBER,
       c_period_id NUMBER,
             p_org_id cn_payruns.org_id%TYPE) IS
        SELECT DISTINCT sprd.role_id
      FROM cn_srp_periods sprd
      WHERE
      sprd.salesrep_id = c_salesrep_id
      AND sprd.period_id = c_period_id
      AND sprd.credit_type_id = -1000
        --R12
        AND org_id = p_org_id;

      G_LAST_UPDATE_DATE          DATE    := sysdate;
      G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
      G_CREATION_DATE             DATE    := sysdate;
      G_CREATED_BY                NUMBER  := fnd_global.user_id;
      G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

      l_has_access BOOLEAN;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Pay_Payrun;
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name    ,
                                        G_PKG_NAME )
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



   --Validate if payrun is valid
   IF ((cn_api.chk_miss_null_num_para
        (p_num_para => p_payrun_id,
         p_obj_name =>
         cn_api.get_lkup_meaning('PAY_RUN_NAME', 'PAY_RUN_VALIDATION_TYPE'),
         p_loading_status => x_loading_status,
         x_loading_status => x_loading_status)) = FND_API.G_TRUE)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN  get_payrun;
   FETCH get_payrun INTO l_payrun_rec;
   IF get_payrun%rowcount = 0 THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAYRUN');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAYRUN';
      CLOSE get_payrun;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
   CLOSE get_payrun;
    l_status_meaning := l_payrun_rec.statusmeaning;

   -- initialize payrun action
   cn_payment_security_pvt.payrun_action
     (p_api_version             => 1.0,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      p_payrun_id               => p_payrun_id,
      p_action                  => 'PAY');
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Need to auto-approve all wkshts if  CN_CHK_WKSHT_STATUS = N
   IF nvl(fnd_profile.value('CN_CHK_WKSHT_STATUS'), 'Y') = 'N' THEN
      -- Lock and Approve all wkshts
      Pay_Payrun_Approve_Wksht
  (x_return_status      => x_return_status,
   x_msg_count          => x_msg_count,
   x_msg_data           => x_msg_data,
   p_payrun_id          => p_payrun_id);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

  -- Check if AP / Payroll integration has been enabled.
   OPEN  get_apps(l_payrun_rec.org_id);
   FETCH get_apps INTO l_payables_flag, l_payroll_flag, l_payables_ccid_level;
   CLOSE get_apps;

  IF l_payroll_flag = 'Y'
     THEN
      IF NOT validate_pay(
       p_payrun                =>p_payrun_id,
       p_pay_date              =>l_payrun_rec.pay_date,
       p_loading_status        =>x_loading_status,
       x_loading_status        =>x_loading_status)
     THEN
      RAISE fnd_api.g_exc_error;
     END IF;
  END IF;

   -- process hold transactions
   UPDATE cn_payment_transactions
     SET payrun_id = '',
     LAST_UPDATE_DATE = Sysdate,
     LAST_UPDATED_BY = G_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = G_LAST_UPDATE_LOGIN
    WHERE payrun_id = p_payrun_id
      AND hold_flag = 'Y'
      --R12
      AND org_id = l_payrun_rec.org_id;

   -- set transactions to paid for this payrun
   UPDATE cn_payment_transactions
     SET paid_flag = 'Y',
     LAST_UPDATE_DATE = Sysdate,
     LAST_UPDATED_BY = G_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = G_LAST_UPDATE_LOGIN
    WHERE payrun_id = p_payrun_id
    --R12
    AND org_id = l_payrun_rec.org_id;


   -- open a transaction (used to be called posting) batch to be used
   -- when PMTPLN_REC payment transactions are added
   cn_prepostbatches.get_UID(l_posting_batch_id);
   l_batch_rec.posting_batch_id := l_posting_batch_id;
   l_batch_rec.name             := 'Payment recoveries for payrun ' ||
                                   p_payrun_id ||'-'||
                                   l_posting_batch_id;

   -- shouldn't need to pass who columns to TH but pass them for now
   l_batch_rec.created_by       := fnd_global.user_id;
   l_batch_rec.creation_date    := sysdate;
   l_batch_rec.last_updated_by  := fnd_global.user_id;
   l_batch_rec.last_update_date := sysdate;
   l_batch_rec.last_update_login:= fnd_global.login_id;

   -- call table handler
   --cn_prepostbatches.insert_record(l_batch_rec);
   -- use old API
   cn_prepostbatches.Begin_Record
     (x_operation              => 'INSERT',
      x_rowid                  => l_rowid,
      x_posting_batch_rec      => l_batch_rec,
      x_program_type           => null,
      p_org_id                 => l_payrun_rec.org_id);

   FOR each_srp IN get_salesreps_in_payrun(l_payrun_rec.org_id)
   LOOP

     l_srp_prd_rec.del_balance1_ctd := 0;
     l_srp_prd_rec.del_balance1_dtd := 0;
     l_srp_prd_rec.del_balance2_ctd := 0;
     l_srp_prd_rec.del_balance4_dtd := 0;
     l_srp_prd_rec.del_balance4_ctd := 0;
     l_srp_prd_rec.del_balance5_dtd := 0;
     l_srp_prd_rec.del_balance5_ctd := 0;
     l_pmt_amount_calc := 0;
     l_ctrl_pmt_amount := 0;
     l_pmt_amount_rec := 0;
     l_pmt_amount_nrec := 0;
     l_recovery := 0;
     l_waive_recovery := 0;
   --  l_hold_pmt := 0;
     l_tot_recovery := 0;
     l_tot_pmt_amount_calc := 0;
     l_pmt_amount_rec := 0;


     -- loop through worksheets with quota_id
     FOR wksht IN get_worksheet_data_for_pe (each_srp.salesrep_id,l_payrun_rec.org_id)
     LOOP

        l_quota_id := wksht.quota_id;
        l_recovery := 0;
        l_pmt_amount_calc := 0;
        l_pmt_amount_rec := 0;
        l_pmt_amount_nrec := 0;
 --       l_hold_pmt := 0;

        -- payment plan amount non-recoverable
        OPEN  get_payment_details(wksht.salesrep_id, wksht.quota_id, l_payrun_rec.org_id);
          FETCH get_payment_details
           INTO l_pmt_amount_calc,
                l_pmt_amount_rec,
                l_pmt_amount_nrec,
                l_recovery;
        CLOSE get_payment_details;
        l_tot_pmt_amount_calc := l_tot_pmt_amount_calc + l_pmt_amount_calc;

        -- control payment
        open  get_control_pmt(wksht.salesrep_id, wksht.quota_id, l_payrun_rec.org_id);
        fetch get_control_pmt into l_ctrl_pmt_amount;
        close get_control_pmt;
        l_pmt_amount_rec := l_pmt_amount_rec + l_ctrl_pmt_amount;

        -- waive recovery
        open  get_waive_rec(wksht.salesrep_id, wksht.quota_id, l_payrun_rec.org_id);
        fetch get_waive_rec into l_waive_recovery;
        close get_waive_rec;

        -- hold payment
        --open  get_hold_pmt(wksht.salesrep_id, wksht.quota_id);
        --fetch get_hold_pmt into l_hold_pmt;
        --close get_hold_pmt;
        l_pmt_amount_rec := nvl(l_pmt_amount_rec, 0);-- - nvl(l_hold_pmt, 0);
        -- manual pay adjustment
        FOR i IN  get_man_pay_adj(wksht.salesrep_id, wksht.quota_id, l_payrun_rec.org_id)
        LOOP
          IF i.recoverable_flag = 'Y'
          THEN
            l_pmt_amount_rec := l_pmt_amount_rec + i.man_pay_adj;
          ELSE
            l_pmt_amount_nrec := l_pmt_amount_nrec + i.man_pay_adj;
          END IF;
        END LOOP;

        -- assign balance columns
        open  get_srp_period(wksht.salesrep_id,
         l_payrun_rec.pay_period_id,
           wksht.quota_id,
                l_payrun_rec.org_id);
  LOOP
     fetch get_srp_period into l_srp_prd_rec.srp_period_id;
     EXIT WHEN get_srp_period%notfound;

        -- changed for bug 2545629
        l_srp_prd_rec.del_balance1_ctd := l_recovery - l_waive_recovery;
        l_srp_prd_rec.del_balance1_dtd := l_pmt_amount_calc +
                                          l_pmt_amount_rec +
                                          l_pmt_amount_nrec;
        l_srp_prd_rec.del_balance2_ctd := l_pmt_amount_calc;
        l_srp_prd_rec.del_balance4_dtd := l_pmt_amount_rec;
        l_srp_prd_rec.del_balance4_ctd := l_recovery ;
        l_srp_prd_rec.del_balance5_dtd := l_pmt_amount_nrec + l_waive_recovery;
        l_srp_prd_rec.del_balance5_ctd := l_pmt_amount_nrec + l_waive_recovery;

        l_tot_recovery := l_tot_recovery + l_recovery;


        -- update srp periods.09-22-03 BUG 3151860 : change to No_Sync
        cn_srp_periods_pvt.Update_Delta_Srp_Pds_No_Sync
     (p_api_version        => 1.0,
        x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_del_srp_prd_rec    => l_srp_prd_rec,
      x_loading_status     => l_loading_status);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
  END LOOP; -- end get_srp_period cursor loop

  -- quota not active in this period, use carry over quota
  IF get_srp_period%ROWCOUNT = 0 THEN

     l_srp_prd_rec.del_balance1_ctd := l_recovery - l_waive_recovery;
     l_srp_prd_rec.del_balance1_dtd := l_pmt_amount_calc +
       l_pmt_amount_rec + l_pmt_amount_nrec;
     l_srp_prd_rec.del_balance2_ctd := l_pmt_amount_calc;
     l_srp_prd_rec.del_balance4_dtd := l_pmt_amount_rec;
     l_srp_prd_rec.del_balance4_ctd := l_recovery ;
     l_srp_prd_rec.del_balance5_dtd := l_pmt_amount_nrec + l_waive_recovery;
     l_srp_prd_rec.del_balance5_ctd := l_pmt_amount_nrec + l_waive_recovery;

     l_tot_recovery := l_tot_recovery + l_recovery;

     OPEN carry_over_srp_period
       (wksht.salesrep_id,l_payrun_rec.pay_period_id, l_payrun_rec.org_id);
     FETCH carry_over_srp_period INTO l_srp_prd_rec.srp_period_id;
     CLOSE carry_over_srp_period;

     -- update srp periods.09-22-03 BUG 3151860 : change to No_Sync
     cn_srp_periods_pvt.Update_Delta_Srp_Pds_No_Sync
       (p_api_version        => 1.0,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_del_srp_prd_rec    => l_srp_prd_rec,
        x_loading_status     => l_loading_status);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
       THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF; -- end IF get_srp_period%ROWCOUNT = 0 THEN

        CLOSE get_srp_period;

        -- contribute to adjusted amount
        l_adj_amount:= l_pmt_amount_rec;

        -- if needed, create PMTPLN_REC records in cn_payment_trasnactions
        IF l_adj_amount <> 0
        THEN
          -- quota ID here actually refers to pay element type ID
          -- quota ID = -1001 for pmt_pln_rec(Bug 2880233)
          l_element_type_id :=
             cn_api.get_pay_element_id(-1001, wksht.salesrep_id, l_payrun_rec.org_id, l_payrun_rec.pay_date);
         END IF;

         IF nvl(l_adj_amount,0) <> 0
         THEN
           -- call table handler
           l_pmt_trx_rec.posting_batch_id     := l_posting_batch_id;
           l_pmt_trx_rec.incentive_type_code  := 'PMTPLN_REC';
           l_pmt_trx_rec.credit_type_id       := l_credit_type_id;
           l_pmt_trx_rec.pay_period_id        := l_payrun_rec.pay_period_id;
           l_pmt_trx_rec.amount               := -l_adj_amount;
           l_pmt_trx_rec.payment_amount       := -l_adj_amount;
           l_pmt_trx_rec.credited_salesrep_id := wksht.salesrep_id;
           l_pmt_trx_rec.payee_salesrep_id    := wksht.salesrep_id;
           l_pmt_trx_rec.paid_flag            := 'N';
           l_pmt_trx_rec.hold_flag            := 'N';
           l_pmt_trx_rec.waive_flag           := 'N';
           l_pmt_trx_rec.pay_element_type_id  := l_element_type_id;
           l_pmt_trx_rec.quota_id             := wksht.quota_id;
           --R12
           l_pmt_trx_rec.org_id               := l_payrun_rec.org_id;
           l_pmt_trx_rec.object_version_number := 1;

           cn_pmt_trans_pkg.insert_record(l_pmt_trx_rec);

        END IF;
     END LOOP; -- worksheets with pe

     -- After Cntpmtrb.pls 115.12.1158.11, cn_payment_transaction cannot create
     -- record with null quota_id, so remove code for handle null quota_id

     -- call sync_accum for this salesrep. 09-22-03 BUG 3151860
     FOR l_sync_accum IN sync_accum(each_srp.salesrep_id,l_payrun_rec.pay_period_id, l_payrun_rec.org_id) LOOP
  cn_srp_periods_pvt.Sync_Accum_Balances_Start_Pd
    (p_salesrep_id     => each_srp.salesrep_id,
       --R12
       p_org_id          => l_payrun_rec.org_id,
     p_credit_type_id  => -1000,
     p_role_id         => l_sync_accum.role_id,
     p_start_period_id => l_payrun_rec.pay_period_id);
     END LOOP;

   END LOOP; -- each srp loop

   cn_payment_security_pvt.paid_payrun_audit
     (p_payrun_id             => p_payrun_id,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);
   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- use if AP / Payroll integration has been enabled.
   IF l_payables_flag = 'Y'
     THEN
      -- Populate ccid's in payment worksheets (already done)
      /* IF (populate_ccids
      (p_payrun_id          => p_payrun_id,
       p_loading_status     => x_loading_status,
       x_loading_status     => x_loading_status
        )) = fnd_api.g_true
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
      */

       -- populate ap interface
       IF (populate_ap_interface
     (p_payrun_id          => p_payrun_id,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status
      )) = fnd_api.g_true
        THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   END IF;
   x_loading_status := 'CN_UPDATED';

   -- Payroll Integration Start here
   -- Added on 02/19/01
   -- Kumar Sivasankaran
   IF l_payroll_flag = 'Y' THEN
      BUILD_BEE_API
        (x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_payrun_id       => p_payrun_id,
         p_loading_status  => x_loading_status,
         x_loading_status  => x_loading_status);

      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   OPEN  get_payrun;
   FETCH get_payrun INTO l_payrun_rec;
   CLOSE get_payrun;

      fnd_message.set_name('CN', 'CN_PMT_UPD_NOTE');
      fnd_message.set_token('NEW', l_payrun_rec.statusmeaning);
      fnd_message.set_token('OLD', l_status_meaning);
      l_note_msg := fnd_message.get;
      jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_payrun_id,
                            p_source_object_code      => 'CN_PAYRUNS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );


   -- End of API body
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
      ROLLBACK TO Pay_Payrun;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Pay_Payrun;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data   ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN OTHERS THEN
      ROLLBACK TO Pay_Payrun;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
END Pay_Payrun;

--============================================================================
--Name :        delete_payrun_conc
--Description : Procedure which will be used as the executable for the
--            : concurrent program. delete payrun
--
--============================================================================
PROCEDURE delete_payrun_conc
     ( errbuf     OUT NOCOPY VARCHAR2,
      retcode   OUT NOCOPY NUMBER ,
      p_name cn_payruns.name%TYPE,
      --R12
      p_org_name hr_operating_units.name%TYPE) IS

     l_proc_audit_id  NUMBER;
     l_return_status  VARCHAR2(1000);
     l_msg_data       VARCHAR2(2000);
     l_msg_count      NUMBER;
     l_loading_status VARCHAR2(1000);
     l_status         VARCHAR2(2000);

     l_payrun_id   NUMBER;


     Cursor get_payrun_id_curs IS
       select cp.payrun_id , cp.org_id,cp.OBJECT_VERSION_NUMBER
         from cn_payruns cp,
            --R12
            hr_operating_units hou
       where cp.name = p_name
        and cp.org_id = hou.organization_id
       and hou.name = p_org_name;

    --R12
    l_org_id cn_payruns.org_id%TYPE;
    l_obj cn_payruns.object_version_number%type;

  BEGIN

    retcode := 0;
    -- Initial message list
    FND_MSG_PUB.initialize;

    -- get payrun id
    open get_payrun_id_curs;
    fetch get_payrun_id_curs into l_payrun_id, l_org_id,l_obj;
    close get_payrun_id_curs;

    cn_message_pkg.begin_batch
     ( x_process_type            => 'DPRUN',
       x_process_audit_id        => l_proc_audit_id,
       x_parent_proc_audit_id    => l_proc_audit_id,
       x_request_id              => NULL,
       --R12
       p_org_id                  => l_org_id
       );

   cn_message_pkg.debug('***************************************************');
   cn_message_pkg.debug('Delete Payrun');

   --call the create worksheet api
     CN_Payrun_PVT.delete_payrun
   (p_api_version       => 1.0,
    p_init_msg_list     => fnd_api.g_true,
    p_commit            => fnd_api.g_false,
    p_validation_level  => fnd_api.g_valid_level_full,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data,
    p_payrun_id         => l_payrun_id,
    p_validation_only => 'N',
    x_status            => l_status,
    x_loading_status    => l_loading_status );

   IF l_return_status <> FND_API.g_ret_sts_success
   THEN
    retcode := 2;
    errbuf := FND_MSG_PUB.get(p_msg_index => fnd_msg_pub.G_LAST,
            p_encoded   => FND_API.G_FALSE);
    cn_message_pkg.debug('Error for delete payrun : '||errbuf);
   ELSE
    COMMIT;
  END IF;

END  delete_payrun_conc;
--============================================================================
END CN_Payrun_PVT;

/
