--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_PERIODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_PERIODS_PVT" AS
--$Header: igwvbprb.pls 115.14 2002/11/14 18:41:02 vmedikon ship $


procedure check_duplicate_period(p_proposal_id         NUMBER
                                ,p_version_id         NUMBER
                                ,p_budget_period_id   NUMBER
                                ,x_return_status  OUT NOCOPY VARCHAR2)  is
  l_exists      VARCHAR2(1);
  l_api_name                    VARCHAR2(30)  := 'CHECK_DUPLICATE_PERIOD';
begin
  select '1'
  into   l_exists
  from   igw_budget_periods
  where  proposal_id = p_proposal_id
  and    version_id =  p_version_id
  and    budget_period_id = p_budget_period_id;

  if l_exists = '1' then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_DUPLICATE_PERIOD');
    Fnd_Message.set_token('PERIOD_ID', p_budget_period_id);
    Fnd_Msg_Pub.Add;
  end if;
exception
  when no_data_found then
    null;
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end;

------------------------------------------------------------------------------------------
procedure validate_period_date (p_proposal_id         NUMBER
                                ,p_version_id         NUMBER
                                ,p_budget_period_id   NUMBER
                                ,p_start_date         DATE
                                ,p_end_date           DATE
                                ,x_return_status  OUT NOCOPY VARCHAR2) is

  cursor c_version is
  select start_date, end_date
  from   igw_budgets
  where  proposal_id = p_proposal_id
  and    version_id =  p_version_id;

  cursor c_budget_line is
  select min(pbpd.start_date)
  ,      max(pbpd.end_date)
  from   igw_budget_details            pbd
  ,      igw_budget_personnel_details  pbpd
  where  pbd.proposal_id = p_proposal_id
  and    pbd.version_id = p_version_id
  and    pbd.budget_period_id = p_budget_period_id
  and    pbd.line_item_id = pbpd.line_item_id;

  l_api_name                    VARCHAR2(30)  := 'VALIDATE_PERIOD_DATE';
  l_version_start_date          DATE;
  l_version_end_date            DATE;
  l_personnel_start_date        DATE;
  l_personnel_end_date          DATE;
begin
  open c_version;
  fetch c_version into l_version_start_date, l_version_end_date;
  close c_version;

  if p_start_date < l_version_start_date OR p_end_date > l_version_end_date then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_PERIOD_OUTSIDE_VERSION');
    Fnd_Msg_Pub.Add;
  end if;

  open c_budget_line;
  fetch c_budget_line into l_personnel_start_date, l_personnel_end_date;
  close c_budget_line;

  if p_start_date > l_personnel_start_date OR p_end_date < l_personnel_end_date then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_PERIOD_OUTSIDE_PERSONNEL');
    Fnd_Msg_Pub.Add;
  end if;
exception
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end;

--------------------------------------------------------------------------------

procedure validate_date_overlap(p_proposal_id        IN  NUMBER
                                ,p_version_id        IN  NUMBER
                                ,p_budget_period_id  IN  NUMBER
                                ,p_date              IN  DATE
                                ,x_return_status     OUT NOCOPY VARCHAR2)  is
  x_dummy varchar2(1);
  l_api_name                    VARCHAR2(30)  := 'VALIDATE_PERIOD_DATE';
begin
    select  '1'
    into    x_dummy
    from    igw_budget_periods
    where   proposal_id = p_proposal_id
    and	    version_id =  p_version_id
    and	    p_date  BETWEEN start_date and end_date
    and	    budget_period_id <> p_budget_period_id
    and     rownum < 2;

    fnd_message.set_name('IGW', 'IGW_BUDGET_DATE_OVERLAP');
    Fnd_Msg_Pub.Add;

exception
  when no_data_found then null;
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end validate_date_overlap;
-------------------------------------------------------------------------------
procedure create_budget_period
       (p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only           IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
  	,p_total_cost		       NUMBER     := 0
  	,p_total_direct_cost	       NUMBER     := 0
	,p_total_indirect_cost	       NUMBER     := 0
	,p_cost_sharing_amount	       NUMBER     := 0
	,p_underrecovery_amount	       NUMBER     := 0
	,p_total_cost_limit	       NUMBER     := 0
	,p_program_income              VARCHAR2   := 0
	,p_program_income_source       VARCHAR2
        ,x_rowid                   OUT NOCOPY ROWID
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2) IS

  l_api_name          VARCHAR2(30)    := 'CREATE_BUDGET_PERIOD';
  l_start_date        DATE            := p_start_date;
  l_end_date          DATE            := p_end_date;
  l_version_id        NUMBER          := p_version_id;
  l_budget_period_id  NUMBER          := p_budget_period_id;
  l_total_cost        NUMBER          := p_total_cost;

  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_data              VARCHAR2(250);
  l_msg_index_out     NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT create_budget_version;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
    end if;

    x_return_status := 'S';

    check_duplicate_period(p_proposal_id
                           ,p_version_id
                           ,p_budget_period_id
                           ,x_return_status  );
    if l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    end if;

    IGW_UTILS.Check_Date_Validity(
                           p_context_field    => 'BUDGET_PERIOD_DATE'
                           ,p_start_date      => nvl(p_start_date, sysdate-1)
                           ,p_end_date        => nvl(p_end_date, sysdate+1)
                           ,x_return_status   => l_return_status);

    if l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    end if;

    validate_period_date(p_proposal_id
                         ,p_version_id
                         ,p_budget_period_id
                         ,p_start_date
                         ,p_end_date
                         ,l_return_status);

    if l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    end if;

    validate_date_overlap(p_proposal_id
                         ,p_version_id
                         ,p_budget_period_id
                         ,p_start_date
                         ,l_return_status);

    if l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    end if;


    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    x_return_status := 'S';

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      l_total_cost := nvl(p_total_indirect_cost,0) + nvl(p_total_direct_Cost,0);
      igw_budget_periods_tbh.insert_row(
	p_proposal_id             => p_proposal_id
	,p_version_id             => p_version_id
        ,p_budget_period_id       => p_budget_period_id
	,p_start_date             => p_start_date
	,p_end_date               => p_end_date
	,p_total_cost             => l_total_cost
	,p_total_direct_cost      => p_total_direct_cost
	,p_total_indirect_cost    => p_total_indirect_cost
	,p_cost_sharing_amount    => p_cost_sharing_amount
	,p_underrecovery_amount   => p_underrecovery_amount
	,p_total_cost_limit       => p_total_cost_limit
	,p_program_income         => p_program_income
	,p_program_income_source  => p_program_income_source
        ,x_rowid                  => x_rowid
        ,x_return_status          => l_return_status);

       x_return_status := l_return_status;

	IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
                                ,p_budget_period_id   => p_budget_period_id
				,x_return_status      => x_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);


    end if; -- p_validate_only = 'Y'

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_version;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --CREATE BUDGET VERSION


------------------------------------------------------------------------------------------
procedure update_budget_period
       (p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only           IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
  	,p_total_cost		       NUMBER
  	,p_total_direct_cost	       NUMBER
	,p_total_indirect_cost	       NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
	,p_total_cost_limit	       NUMBER
	,p_program_income              VARCHAR2
	,p_program_income_source       VARCHAR2
        ,p_record_version_number   IN  NUMBER
        ,p_rowid                   IN  ROWID
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2) IS

  l_api_name          VARCHAR2(30)    := 'UPDATE_BUDGET_PERIOD';
  l_start_date        DATE            := p_start_date;
  l_end_date          DATE            := p_end_date;
  l_version_id        NUMBER          := p_version_id;
  l_budget_period_id  NUMBER          := p_budget_period_id;
  l_orig_budget_period_id  NUMBER     := p_budget_period_id;
  l_total_cost        NUMBER          := p_total_cost;

  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_data              VARCHAR2(250);
  l_msg_index_out     NUMBER;
  l_dummy             VARCHAR2(1);

BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_budget_version;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    x_return_status := 'S';


    if p_rowid is not null then
      select budget_period_id
      into   l_orig_budget_period_id
      from   igw_budget_periods
      where  rowid = p_rowid;
    end if;


    /* check for duplicate period if the new period is different from the old period */
    if l_orig_budget_period_id <> p_budget_period_id then
      check_duplicate_period(p_proposal_id
                           ,p_version_id
                           ,p_budget_period_id
                           ,x_return_status  );
      if l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      end if;
    end if;

    IGW_UTILS.Check_Date_Validity(
                           p_context_field    => 'BUDGET_PERIOD_DATE'
                           ,p_start_date      => nvl(p_start_date, sysdate-1)
                           ,p_end_date        => nvl(p_end_date, sysdate+1)
                           ,x_return_status   => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    END IF;

    validate_period_date(p_proposal_id
                         ,p_version_id
                         ,p_budget_period_id
                         ,p_start_date
                         ,p_end_date
                         ,l_return_status);

    if l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    end if;

    validate_date_overlap(p_proposal_id
                         ,p_version_id
                         ,l_orig_budget_period_id
                         ,p_start_date
                         ,l_return_status);

    if l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    end if;




    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    BEGIN
      SELECT 'x' INTO l_dummy
      FROM   igw_budget_periods
      WHERE  ((proposal_id  = p_proposal_id  AND   version_id = p_version_id
                       AND budget_period_id = p_budget_period_id)
	 OR rowid = p_rowid)
      AND record_version_number  = p_record_version_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
        FND_MSG_PUB.Add;
        x_msg_data := 'IGW_SS_RECORD_CHANGED';
        x_return_status := 'E' ;
    END;

    l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         If l_msg_count = 1 THEN
          fnd_msg_pub.get
           (p_encoded        => FND_API.G_TRUE ,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out );

            x_msg_data := l_data;
         End if;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      l_total_cost := nvl(p_total_indirect_cost,0) + nvl(p_total_direct_Cost,0);

      igw_budget_periods_tbh.update_row(
        p_rowid                   =>  p_rowid
	,p_proposal_id            => p_proposal_id
	,p_version_id             => p_version_id
        ,p_budget_period_id       => p_budget_period_id
	,p_start_date             => p_start_date
	,p_end_date               => p_end_date
	,p_total_cost             => l_total_cost
	,p_total_direct_cost      => p_total_direct_cost
	,p_total_indirect_cost    => p_total_indirect_cost
	,p_cost_sharing_amount    => p_cost_sharing_amount
	,p_underrecovery_amount   => p_underrecovery_amount
	,p_total_cost_limit       => p_total_cost_limit
	,p_program_income         => p_program_income
	,p_program_income_source  => p_program_income_source
        ,p_record_version_number  => p_record_version_number
        ,x_return_status          => l_return_status);

       x_return_status := l_return_status;

       --also update the corresponding detail records to reflect new budget period id
       if l_orig_budget_period_id <> p_budget_period_id then
         update igw_budget_details
         set    budget_period_id = p_budget_period_id
         where  proposal_id = p_proposal_id
         and    version_id = p_version_id
         and    budget_period_id = l_orig_budget_period_id;

         update igw_budget_details_cal_amts
         set    budget_period_id = p_budget_period_id
         where  proposal_id = p_proposal_id
         and    version_id = p_version_id
         and    budget_period_id = l_orig_budget_period_id;

         update igw_budget_personnel_details
         set    budget_period_id = p_budget_period_id
         where  proposal_id = p_proposal_id
         and    version_id = p_version_id
         and    budget_period_id = l_orig_budget_period_id;
       end if;




	IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
                                ,p_budget_period_id   => p_budget_period_id
				,x_return_status      => x_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);


    end if; -- p_validate_only = 'Y'

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_version;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;

END; --UPDATE BUDGET VERSIONS

-------------------------------------------------------------------------------------------

procedure delete_budget_period
       (p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only           IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_record_version_number   IN  NUMBER
        ,p_rowid                   IN  ROWID
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2)  is

  l_api_name          VARCHAR2(30)    := 'DELETE_BUDGET_PERIOD';
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_data              VARCHAR2(250);
  l_msg_index_out     NUMBER;
  l_dummy             VARCHAR2(1);



BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT delete_budget_version;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    x_return_status := 'S';

    BEGIN
      SELECT 'x' INTO l_dummy
      FROM   igw_budget_periods
      WHERE  ((proposal_id  = p_proposal_id  AND   version_id = p_version_id
                       AND budget_period_id = p_budget_period_id)
	 OR rowid = p_rowid)
      AND record_version_number  = p_record_version_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
        FND_MSG_PUB.Add;
        x_msg_data := 'IGW_SS_RECORD_CHANGED';
        x_return_status := 'E' ;
    END;

    l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         If l_msg_count = 1 THEN
          fnd_msg_pub.get
           (p_encoded        => FND_API.G_TRUE ,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out );

            x_msg_data := l_data;
         End if;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

     igw_budget_periods_tbh.delete_row (
       p_rowid => p_rowid,
       p_proposal_id => p_proposal_id,
       p_version_id =>  p_version_id,
       p_budget_period_id => p_budget_period_id,
       p_record_version_number => p_record_version_number,
       x_return_status => l_return_status);


       igw_budgets_pvt.manage_budget_deletion(
                   p_delete_level        =>  'BUDGET_PERIOD'
		   ,p_proposal_id        =>  p_proposal_id
		   ,p_version_id         =>  p_version_id
                   ,p_budget_period_id   =>  p_budget_period_id
                   ,x_return_status      =>  l_return_status);

       x_return_status := l_return_status;

	IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
				,x_return_status      => x_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);

    end if; -- p_validate_only = 'Y'


    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
  IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_version;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --DELETE BUDGET VERSION


END IGW_BUDGET_PERIODS_PVT;

/
