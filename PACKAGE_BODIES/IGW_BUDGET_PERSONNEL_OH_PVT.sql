--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_PERSONNEL_OH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_PERSONNEL_OH_PVT" AS
--$Header: igwvbpob.pls 115.8 2002/11/14 18:41:45 vmedikon ship $



----------------------------------------------------------------------------------
/*
  procedure create_budget_line_oh
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER
        ,p_line_item_id                     NUMBER
        ,p_rate_class_id                    NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_apply_rate_flag                  VARCHAR2
        ,p_calculated_cost                  NUMBER     := 0
        ,p_calculated_cost_sharing          NUMBER     := 0
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_api_name                   VARCHAR2(30)    :='CREATE_BUDGET_LINE_OH';
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_data                       VARCHAR2(250);
  l_msg_index_out              NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT create_budget_line_oh;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
    end if;

    x_return_status := 'S';

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
      igw_generate_periods.create_budget_detail_amts(
           p_proposal_id          => p_proposal_id
           ,p_version_id          => p_version_id
           ,p_budget_period_id    => p_budget_period_id
           ,p_line_item_id        => p_line_item_id
           ,p_rate_class_id       => p_rate_class_id
           ,p_rate_type_id        => p_rate_type_id
           ,p_apply_rate_flag     => p_apply_rate_flag
           ,p_calculated_cost     => p_calculated_cost
           ,p_calculated_cost_sharing  => p_calculated_cost_sharing);

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
       ROLLBACK TO create_budget_line_oh;
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
       ROLLBACK TO create_budget_line_oh;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_line_oh;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --CREATE BUDGET

*/
------------------------------------------------------------------------------------------
  procedure update_budget_personnel_oh
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_budget_personnel_detail_id       NUMBER
        ,p_rate_class_id                    NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_apply_rate_flag_oh               VARCHAR2
        ,p_apply_rate_flag_eb               VARCHAR2
        ,p_calculated_cost                  NUMBER
        ,p_calculated_cost_sharing          NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_api_name                   VARCHAR2(30)     :='UPDATE_BUDGET_PERSONNEL_OH';
  l_proposal_id                NUMBER;
  l_version_id                 NUMBER;
  l_budget_period_id           NUMBER;
  l_line_item_id               NUMBER;
  l_calculated_cost            NUMBER           := p_calculated_cost;
  l_calculated_cost_sharing    NUMBER           := p_calculated_cost_sharing;
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_data                       VARCHAR2(250);
  l_msg_index_out              NUMBER;
  l_dummy                      VARCHAR2(1);

BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_budget_personnel_oh;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    x_return_status := 'S';


    BEGIN
      SELECT 'x' INTO l_dummy
      FROM   igw_budget_personnel_cal_amts
      WHERE  ((budget_personnel_detail_id  = p_budget_personnel_detail_id
                     and rate_class_id = p_rate_class_id   --bug 2515925
	             and rate_type_id = p_rate_type_id)    --bug 2515925
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

   /* need to this because following ids may not be passed and only row id may be passed */

      select proposal_id, version_id, budget_period_id, line_item_id
      into   l_proposal_id, l_version_id, l_budget_period_id, l_line_item_id
      from   igw_budget_personnel_details
      where  budget_personnel_detail_id  = p_budget_personnel_detail_id;


    if (p_apply_rate_flag_oh = 'N' or p_apply_rate_flag_eb = 'N') then
      l_calculated_cost := 0;
      l_calculated_cost_sharing := 0;
    end if;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      update igw_budget_personnel_cal_amts
      set    apply_rate_flag = nvl(p_apply_rate_flag_oh, apply_rate_flag)
      ,      calculated_cost = l_calculated_cost
      ,      calculated_cost_sharing = l_calculated_cost_sharing
      ,      record_version_number = record_version_number + 1
      where  budget_personnel_detail_id  = p_budget_personnel_detail_id
      and    rate_class_id IN (select rate_class_id from igw_rate_classes where rate_class_type = 'O');

      update igw_budget_personnel_cal_amts
      set    apply_rate_flag = nvl(p_apply_rate_flag_eb, apply_rate_flag)
      ,      calculated_cost = l_calculated_cost
      ,      calculated_cost_sharing = l_calculated_cost_sharing
      ,      record_version_number = record_version_number + 1
      where  budget_personnel_detail_id  = p_budget_personnel_detail_id
      and    rate_class_id IN (select rate_class_id from igw_rate_classes where rate_class_type = 'E');


      IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => l_proposal_id
				,p_version_id         => l_version_id
                                ,p_budget_period_id   => l_budget_period_id
                                ,p_line_item_id       => l_line_item_id
                                ,p_budget_personnel_detail_id => p_budget_personnel_detail_id
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
       ROLLBACK TO update_budget_personnel_oh;
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
       ROLLBACK TO update_budget_personnel_oh;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_line_oh;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;

END; --UPDATE BUDGET PERSONNEL OH

-------------------------------------------------------------------------------------------
/*

procedure delete_budget_line_oh
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER     := NULL
        ,p_version_id                   IN  NUMBER     := NULL
        ,p_budget_period_id                 NUMBER     := NULL
        ,p_line_item_id                     NUMBER
        ,p_rate_class_id                    NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2)  is

  l_api_name          VARCHAR2(30)    :='DELETE_BUDGET_LINE_OH';
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_data              VARCHAR2(250);
  l_msg_index_out     NUMBER;
  l_dummy             VARCHAR2(1);



BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT delete_budget_line_oh;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    x_return_status := 'S';

    BEGIN
      SELECT 'x' INTO l_dummy
      FROM    igw_budget_details_cal_amts
      WHERE  ((line_item_id  = p_line_item_id and rate_class_id = p_rate_class_id and rate_type_id = p_rate_type_id)
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
       delete from igw_budget_details_cal_amts
       where  line_item_id = p_line_item_id
       and    rate_class_id = p_rate_class_id
       and    rate_type_id = p_rate_type_id;

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
       ROLLBACK TO delete_budget_line_oh;
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
       ROLLBACK TO delete_budget_line_oh;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_line_oh;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --DELETE BUDGET LINE OH
*/

END;

/
