--------------------------------------------------------
--  DDL for Package Body CSP_FORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_FORECAST_PVT" AS
/* $Header: cspvpfob.pls 120.1 2006/02/03 00:54:34 hhaugeru noship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_FORECAST_PVT';


FUNCTION  period_end_date(
  p_organization_id     IN  NUMBER,
  p_period_type         IN  NUMBER,
  p_period_start_date   IN  DATE)
  RETURN DATE IS

  l_end_date                DATE;

  cursor c_end_date is
  select schedule_close_date end_date
  from   org_acct_periods
  where  period_start_date = trunc(p_period_start_date)
  and    organization_id = p_organization_id
  order by period_start_date asc;

begin
  if p_period_type = 1 then --Weekly
    l_end_date := trunc(p_period_start_date) + 6;
  elsif p_period_type = 2 then  --Periodic
    open  c_end_date;
    fetch c_end_date into l_end_date;
    close c_end_date;
  end if;
  return l_end_date;
end;

PROCEDURE period_start_dates(
  p_start_date          IN  DATE,
  p_period_type         IN  NUMBER,
  p_number_of_periods   IN  NUMBER,
  p_organization_id     IN  NUMBER,
  x_period_start_dates      OUT NOCOPY csp_forecast_pvt.t_date_table) IS

  l_count                   NUMBER := 0;
  l_start_date              DATE;

  cursor c_next_period(c_start_date DATE) is
  /*select start_date
  from   org_acct_periods_v
  where  start_date >= c_start_date
  and    organization_id = p_organization_id
  order by start_date asc;*/
  select PERIOD_START_DATE
  from   ORG_ACCT_PERIODS
  where PERIOD_START_DATE >= c_start_date
  and    organization_id = p_organization_id
  order by PERIOD_START_DATE asc;

  cursor c_previous_period(c_start_date DATE) is
  /*select start_date
  from   org_acct_periods_v
  where  start_date < c_start_date
  and    organization_id = p_organization_id
  order by start_date desc;*/
  select PERIOD_START_DATE
  from   ORG_ACCT_PERIODS
  where PERIOD_START_DATE < c_start_date
  and    organization_id = p_organization_id
  order by PERIOD_START_DATE desc;

begin
  -- History
  if p_number_of_periods < 0 then
    if p_period_type = 1 then -- Weekly
      l_start_date := trunc(p_start_date-7,'IW');
      for l_count in 0..abs(p_number_of_periods) loop
        x_period_start_dates(l_count) := l_start_date - 7 * l_count;
      end loop;
    elsif p_period_type = 2 then -- Periodic
      open  c_previous_period(p_start_date);
      fetch c_previous_period into l_start_date;
      close c_previous_period;
      for l_count in 0..abs(p_number_of_periods) loop
        open  c_previous_period(l_start_date);
        fetch c_previous_period into l_start_date;
        close c_previous_period;
        x_period_start_dates(l_count) := l_start_date;
      end loop;
    end if;
  -- Forecast
  else
    if p_period_type = 1 then
      l_start_date := trunc(p_start_date,'IW');
      for l_count in 1..abs(p_number_of_periods) loop
        x_period_start_dates(l_count) := l_start_date + 7 * (l_count-1);
      end loop;
    elsif p_period_type = 2 then -- Periodic
      open  c_previous_period(p_start_date);
      fetch c_previous_period into l_start_date;
      close c_previous_period;
      open  c_next_period(l_start_date);
      for l_count in 1..abs(p_number_of_periods) loop
        fetch c_next_period into l_start_date;
        x_period_start_dates(l_count) := l_start_date;
      end loop;
      close c_next_period;
    end if;


  end if;
end;

PROCEDURE simple_average(
  p_usage_history       IN  csp_forecast_pvt.t_number_table,
  p_history_periods     IN  NUMBER,
  p_forecast_periods    IN  NUMBER,
  x_forecast_quantities OUT NOCOPY csp_forecast_pvt.t_number_table) IS

  l_count                   NUMBER;
  l_total_quantity          NUMBER := 0;
  l_forecast                NUMBER;

begin
  for l_count in 0..p_history_periods-1 loop
    l_total_quantity := l_total_quantity + p_usage_history(l_count);
  end loop;
  l_forecast := l_total_quantity / p_history_periods;
  for l_count in 1..p_forecast_periods loop
    x_forecast_quantities(l_count) := l_forecast;
  end loop;
end simple_average;

PROCEDURE weighted_average(
  p_usage_history           IN  csp_forecast_pvt.t_number_table,
  p_history_periods         IN  NUMBER,
  p_forecast_periods        IN  NUMBER,
  p_weighted_avg            IN  csp_forecast_pvt.t_number_table,
  x_forecast_quantities     OUT NOCOPY csp_forecast_pvt.t_number_table) IS

  l_count                   NUMBER;
  l_count1                  NUMBER := 0;
  l_forecast                NUMBER := 0;

begin
  for l_count in 0..p_history_periods-1 loop
    l_count1:=l_count+1;
    l_forecast := l_forecast + p_usage_history(l_count) * p_weighted_avg(l_count1);
  end loop;
  for l_count in 1..p_forecast_periods loop
    x_forecast_quantities(l_count) := l_forecast;
  end loop;
end weighted_average;

PROCEDURE exponential_smoothing(
  p_usage_history           IN  csp_forecast_pvt.t_number_table,
  p_history_periods         IN  NUMBER,
  p_forecast_periods        IN  NUMBER,
  p_alpha                   IN  NUMBER,
  x_forecast_quantities     OUT NOCOPY csp_forecast_pvt.t_number_table) IS

  l_count                   NUMBER := 0;
  l_forecast                NUMBER := 0;
  l_actual                  NUMBER := 0;

begin
  l_forecast := p_usage_history(0);
  for l_count in 1..p_history_periods-1 loop
    l_forecast := p_usage_history(l_count) * p_alpha + l_forecast * (1 - p_alpha);
  end loop;
  for l_count in 1..p_forecast_periods loop
    x_forecast_quantities(l_count) := l_forecast;
  end loop;
end exponential_smoothing;

PROCEDURE trend_enhanced(
  p_usage_history           IN  csp_forecast_pvt.t_number_table,
  p_history_periods         IN  NUMBER,
  p_forecast_periods        IN  NUMBER,
  p_alpha                   IN  NUMBER,
  p_beta                    IN  NUMBER,
  x_forecast_quantities     OUT NOCOPY csp_forecast_pvt.t_number_table) IS

  l_count                   NUMBER := 0;
  l_forecast                NUMBER := 0;
  l_actual                  NUMBER := 0;
  l_base                    NUMBER := 0;
  l_trend                   NUMBER := 0;
  l_previous_base           NUMBER := 0;

begin
  l_base := p_usage_history(0);
  for l_count in 1..p_history_periods-1 loop
    l_previous_base := l_base;
    l_base := p_usage_history(l_count) * p_alpha + l_base * (1 - p_alpha);
    if l_count = 1 then
      l_trend := p_usage_history(1) - p_usage_history(0);
    else
      l_trend := (l_base - l_previous_base) * p_beta + l_trend * (1 - p_beta);
    end if;
  end loop;
  for l_count in 1..p_forecast_periods loop
    x_forecast_quantities(l_count) := l_base + l_trend * l_count;
  end loop;
end trend_enhanced;
PROCEDURE create_forecast(
  p_api_version         IN  NUMBER,
  p_parts_loop_id       IN  NUMBER,
  p_organization_id     IN  NUMBER,
  p_subinventory_code   IN  VARCHAR2 ,
  p_inventory_item_id   IN  NUMBER,
  p_start_date          IN  DATE,
  x_start_date          OUT NOCOPY DATE,
  x_end_date            OUT NOCOPY DATE,
  x_period_type         OUT NOCOPY NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_forecast_pvt';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_start_date              DATE;
  l_start_date1             DATE;
  l_end_date                DATE;
  l_count                   NUMBER := 0;
  l_count1                  NUMBER := 0;
  l_usage_id                NUMBER;
  l_used_quantity           NUMBER;
  l_so_quantity             NUMBER;
  l_index		    NUMBER := 0;

  l_usage_history           T_NUMBER_TABLE;
  l_forecast_quantities     T_NUMBER_TABLE;
  l_weighted_avg            T_NUMBER_TABLE;
  l_forecast_dates          T_DATE_TABLE;
  l_history_dates           T_DATE_TABLE;

  cursor c_usage_history Is
  select sum(quantity) usage_quantity
  from   csp_usage_histories
  where  parts_loop_id      = nvl(p_parts_loop_id,parts_loop_id)
  and    organization_id    = p_organization_id
  and    subinventory_code  = nvl(p_subinventory_code,subinventory_code)
  and    inventory_item_id  = p_inventory_item_id
  and    history_data_type = 0
  Group by Period_Start_date
  Order by period_start_date desc;

  cursor c_forecast_info is
  select cfrb.period_size,
	 cfrb.forecast_rule_id,
         cfrb.period_type,
         cfrb.forecast_method,
         cfrb.forecast_periods,
         cfrb.history_periods,
         cfrb.alpha,
         cfrb.beta,
         cfrb.weighted_avg_period1,
         cfrb.weighted_avg_period2,
         cfrb.weighted_avg_period3,
         cfrb.weighted_avg_period4,
         cfrb.weighted_avg_period5,
         cfrb.weighted_avg_period6,
         cfrb.weighted_avg_period7,
         cfrb.weighted_avg_period8,
         cfrb.weighted_avg_period9,
         cfrb.weighted_avg_period10,
         cfrb.weighted_avg_period11,
         cfrb.weighted_avg_period12
   from  csp_forecast_rules_b cfrb,
         csp_parts_loops_b cplb
   where cfrb.forecast_rule_id = cplb.forecast_rule_id
   and   cplb.parts_loop_id = p_parts_loop_id;

   l_rec        c_forecast_info%rowtype;
   l_forecast_qty Number := 0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  create_forecast_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version   ,
                                      p_api_version   ,
                                      l_api_name      ,
                                      G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  open  c_forecast_info;
  fetch c_forecast_info into l_rec;
  close c_forecast_info;
  For l_Index in 0..l_rec.history_periods - 1 Loop
      l_Usage_history(l_index) := 0;
  End Loop;
  l_index := 0;
  For l_usg in c_usage_history Loop
      l_usage_history(l_index) := nvl(l_usg.usage_quantity,0);
      l_index := l_index + 1;
  End loop;

  if l_rec.forecast_method = 1 then
    simple_average(
      p_usage_history         =>  l_usage_history,
      p_history_periods       =>  l_rec.history_periods,
      p_forecast_periods      =>  l_rec.forecast_periods,
      x_forecast_quantities   =>  l_forecast_quantities);
  elsif l_rec.forecast_method = 2 then
    l_weighted_avg(1) := l_rec.weighted_avg_period1;
    l_weighted_avg(2) := l_rec.weighted_avg_period2;
    l_weighted_avg(3) := l_rec.weighted_avg_period3;
    l_weighted_avg(4) := l_rec.weighted_avg_period4;
    l_weighted_avg(5) := l_rec.weighted_avg_period5;
    l_weighted_avg(6) := l_rec.weighted_avg_period6;
    l_weighted_avg(7) := l_rec.weighted_avg_period7;
    l_weighted_avg(8) := l_rec.weighted_avg_period8;
    l_weighted_avg(9) := l_rec.weighted_avg_period9;
    l_weighted_avg(10) := l_rec.weighted_avg_period10;
    l_weighted_avg(11) := l_rec.weighted_avg_period11;
    l_weighted_avg(12) := l_rec.weighted_avg_period12;
    weighted_average(
      p_usage_history         =>  l_usage_history,
      p_history_periods       =>  l_rec.history_periods,
      p_forecast_periods      =>  l_rec.forecast_periods,
      p_weighted_avg          =>  l_weighted_avg,
      x_forecast_quantities   =>  l_forecast_quantities);
  elsif l_rec.forecast_method = 3 then
    exponential_smoothing(
      p_usage_history       => l_usage_history,
      p_history_periods     => l_rec.history_periods,
      p_forecast_periods    => l_rec.forecast_periods,
      p_alpha               => l_rec.alpha,
      x_forecast_quantities => l_forecast_quantities);
  elsif l_rec.forecast_method = 4 then
    trend_enhanced(
      p_usage_history       => l_usage_history,
      p_history_periods     => l_rec.history_periods,
      p_forecast_periods    => l_rec.forecast_periods,
      p_alpha               => l_rec.alpha,
      p_beta                => l_rec.beta,
      x_forecast_quantities => l_forecast_quantities);
  end if;
  for l_count in 1..l_rec.forecast_periods loop
    l_usage_id := null;
    If l_forecast_quantities(l_count) > 0 Then
       l_forecast_qty := l_forecast_quantities(l_count);
       Else
	l_forecast_qty := 0;
    End If;
    csp_usage_histories_pkg.insert_row(
        px_usage_id           => l_usage_id,
        p_created_by          => fnd_global.user_id,
        p_creation_date       => sysdate,
        p_last_updated_by     => fnd_global.user_id,
        p_last_update_date    => sysdate,
        p_last_update_login   => null,
        p_inventory_item_id   => p_inventory_item_id,
        p_organization_id     => p_organization_id,
        p_period_type         => l_rec.period_type,
        p_period_start_date   => sysdate + ((l_count - 1) * l_rec.period_size),
        p_quantity            => l_forecast_qty,
        p_request_id          => null,
        p_program_application_id => null,
        p_program_id          => null,
        p_program_update_date => null,
        p_subinventory_code   => nvl(p_subinventory_code,'-'),
        p_transaction_type_id => -1,
        p_hierarchy_node_id   => null,
        p_parts_loop_id       => p_parts_loop_id,
	p_history_data_type   => 0,
        p_attribute_category  => null,
        p_attribute1          => null,
        p_attribute2          => null,
        p_attribute3          => null,
        p_attribute4          => null,
        p_attribute5          => null,
        p_attribute6          => null,
        p_attribute7          => null,
        p_attribute8          => null,
        p_attribute9          => null,
        p_attribute10         => null,
        p_attribute11         => null,
        p_attribute12         => null,
        p_attribute13         => null,
        p_attribute14         => null,
        p_attribute15         => null);
  end loop;

  x_period_type := l_rec.period_type;
  x_start_date  := trunc(sysdate) - l_rec.history_periods * l_rec.period_size;
  x_end_date    := trunc(sysdate) + (l_rec.forecast_periods - 1) * l_rec.period_size;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => null
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
    WHEN OTHERS THEN
      JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => null
            ,X_MSG_COUNT    => X_MSG_COUNT
            ,X_MSG_DATA     => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
end;


PROCEDURE rollback_forecast IS
begin
  rollback to create_forecast_pvt;
end;


end;



/
