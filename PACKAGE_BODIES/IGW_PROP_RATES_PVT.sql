--------------------------------------------------------
--  DDL for Package Body IGW_PROP_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_RATES_PVT" AS
-- $Header: igwvprtb.pls 115.5 2002/11/15 00:44:31 ashkumar ship $

procedure PROCESS_PROP_RATES
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      NUMBER
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code               VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,p_rowid                    IN  OUT NOCOPY ROWID
        ,p_record_version_number            NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  cursor c_rates is
  select rowid
  from   igw_prop_rates
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id
  and    rate_class_id = p_rate_class_id
  and    rate_type_id = p_rate_type_id
  and    location_code = p_location_code
  and    activity_type_code = p_activity_type_code
  and    fiscal_year = p_fiscal_year;

  l_api_name                 VARCHAR2(30)      := 'PROCESS_PROP_RATES';
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT process_prop_rates;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
    end if;

    x_return_status := 'S';
    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
      open c_rates;
      fetch c_rates into p_rowid;
      if (c_rates%notfound) then
        igw_prop_rates_tbh.insert_row(
	  p_proposal_id           => p_proposal_id
  	  ,p_version_id           => p_version_id
	  ,p_rate_class_id        => p_rate_class_id
	  ,p_rate_type_id         => p_rate_type_id
	  ,p_fiscal_year          => to_char(p_fiscal_year)
	  ,p_location_code        => p_location_code
	  ,p_activity_type_code   => p_activity_type_code
	  ,p_start_date           => p_start_date
	  ,p_applicable_rate      => p_applicable_rate
	  ,p_institute_rate       => p_institute_rate
          ,x_rowid                => p_rowid
          ,x_return_status        => l_return_status);

         x_return_status := l_return_status;
      else
        igw_prop_rates_tbh.update_row(
	  p_proposal_id           => p_proposal_id
  	  ,p_version_id           => p_version_id
	  ,p_rate_class_id        => p_rate_class_id
	  ,p_rate_type_id         => p_rate_type_id
	  ,p_fiscal_year          => to_char(p_fiscal_year)
	  ,p_location_code        => p_location_code
	  ,p_activity_type_code   => p_activity_type_code
	  ,p_start_date           => p_start_date
	  ,p_applicable_rate      => p_applicable_rate
	  ,p_institute_rate       => p_institute_rate
          ,p_rowid                => p_rowid
          ,p_record_version_number =>p_record_version_number
          ,x_return_status        => l_return_status);
      end if;
      close c_rates;

	IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
				,x_return_status      => l_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);

      x_return_status := l_return_status;
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
       ROLLBACK TO process_prop_rates;
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
       ROLLBACK TO process_prop_rates;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO process_prop_rates;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --Process prop rates


END;

/
