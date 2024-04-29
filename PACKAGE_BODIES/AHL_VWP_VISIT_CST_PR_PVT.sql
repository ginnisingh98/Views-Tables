--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISIT_CST_PR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISIT_CST_PR_PVT" AS
/* $Header: AHLVVCPB.pls 120.4 2007/12/18 09:59:26 sowsubra ship $ */

-- PACKAGE
--    Ahl_VWP_VISIT_CST_PR_PVT
--
-- PURPOSE
--    This package is a Private API to process Estimating Cost and Price
--    for a Visit It contains specification for pl/sql records and tables
--
--
-- NOTES
--
--
-- HISTORY
-- 25-AUG-2003    SSURAPAN      Created.
--
--
-- PROCEDURES
--       get_visit_cost_details   -- update_visit_cost_details
--       estimate_visit_cost      -- estimate_visit_price
--       create_price_snapshot    -- create_cost_snapshot
--       get_visit_items_no_price -- check_for_release_visit

--
-- Package/App Name
  G_PKG_NAME         CONSTANT  VARCHAR(30) := 'AHL_VWP_VISIT_CST_PR_PVT';
  G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';

--------------------------------------------------------------------------
-- Procedure to estimate price for a specific SR --
--------------------------------------------------------------------------
PROCEDURE Estimate_SR_Price(
    p_x_cost_price_rec     IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2);

--------------------------------------------------------------------------
-- Procedure to get visit cost details for a specific visit --
--------------------------------------------------------------------------
PROCEDURE get_visit_cost_details(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2) IS

-- Define Local Variables
    L_API_VERSION          CONSTANT NUMBER := 1.0;
    L_API_NAME             CONSTANT VARCHAR2(30) := 'get_visit_cost_details';
    L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

    l_cost_price_rec       AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type;
    l_error_msg_code VARCHAR2(240);
    l_exists         VARCHAR2(1);

    l_visit_status   VARCHAR2(30);


-- Define Local Cursors
    CURSOR visit_info_csr(p_visit_id IN NUMBER) IS
    SELECT status_code, outside_party_flag, price_list_id, actual_price, estimated_price,
           any_task_chg_flag, service_request_id, start_date_time, close_date_time
    FROM ahl_visits_b
    WHERE visit_id = p_visit_id;

    CURSOR customer_id_csr(p_service_request_id IN NUMBER)IS
    SELECT customer_id FROM cs_incidents_all_b
    WHERE incident_id = p_service_request_id;

    CURSOR visit_tasks_csr(p_visit_id IN NUMBER) IS
    SELECT 'x' FROM ahl_visit_tasks_b
    WHERE visit_id = p_visit_id
    and nvl(status_code, 'x') <>'DELETED';

    CURSOR price_list_name_csr(p_price_list_id IN NUMBER) IS
    SELECT name from qp_list_headers_vl
    WHERE list_header_id = p_price_list_id;

-- Begin Procedure code
BEGIN
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details.begin',
      'At the start of PLSQL procedure'
    );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT get_visit_cost_details;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to check for call compatibility.
     IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
     THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_cost_price_rec:= p_x_cost_price_rec;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
      'Got request for cost record of Visit ID : ' || p_x_cost_price_rec.visit_id
    );
        fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
      'Got request for update visit cost details of mr session ID : ' || p_x_cost_price_rec.mr_session_id
    );
        fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
      'Got request for update visit cost details of cost session ID : ' || p_x_cost_price_rec.cost_session_id
    );
     END IF;

     -- make sure that visit id is present in the input
     IF(p_x_cost_price_rec.visit_id IS NULL OR p_x_cost_price_rec.visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     OPEN visit_info_csr(p_x_cost_price_rec.visit_id);
     FETCH visit_info_csr INTO l_visit_status,
          l_cost_price_rec.outside_party_flag,
          l_cost_price_rec.price_list_id,
          l_cost_price_rec.actual_price, l_cost_price_rec.estimated_price,
          l_cost_price_rec.Is_Cst_Struc_updated, l_cost_price_rec.service_request_id,
          l_cost_price_rec.visit_start_date, l_cost_price_rec.visit_end_date;

        IF (visit_info_csr%NOTFOUND)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_exception,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
              'Visit id not found in ahl_visits_b table'
            );
            END IF;
            CLOSE visit_info_csr;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     CLOSE visit_info_csr;


     -- outside party flag can be updated only when service request id is not null
     IF(l_cost_price_rec.service_request_id IS NOT NULL)THEN

        -- find out the customer id
        OPEN customer_id_csr(l_cost_price_rec.service_request_id);
        FETCH customer_id_csr INTO l_cost_price_rec.customer_id;
        IF(customer_id_csr%NOTFOUND)THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_SR_ID');
           FND_MSG_PUB.ADD;
           IF(fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
           fnd_log.level_unexpected,
           'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
           'Service request associated is invalid as record not found : l_cost_price_rec.service_request_id : '||l_cost_price_rec.service_request_id
          );
           END IF;
           CLOSE customer_id_csr;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE customer_id_csr;

        -- can outside party flag be updated?
        OPEN visit_tasks_csr(p_x_cost_price_rec.visit_id);
        FETCH visit_tasks_csr INTO l_exists;
        IF(visit_tasks_csr%NOTFOUND)THEN
          l_cost_price_rec.is_outside_pty_flag_updt := 'Y';
        ELSE
          l_cost_price_rec.is_outside_pty_flag_updt := 'N';
        END IF;
        CLOSE visit_tasks_csr;

     ELSE
        l_cost_price_rec.is_outside_pty_flag_updt := 'N';
     END IF;

     -- To find out price list name
     IF(l_cost_price_rec.price_list_id IS NOT NULL)THEN
        OPEN price_list_name_csr(l_cost_price_rec.price_list_id);
        FETCH price_list_name_csr INTO l_cost_price_rec.price_list_name;

        IF(price_list_name_csr%NOTFOUND)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
          'List name not found for stored list id'
        );
          END IF;
          CLOSE price_list_name_csr;
          RAISE  FND_API.G_EXC_ERROR;
        END IF;

        CLOSE price_list_name_csr;
     END IF;

     -- To find currency here
     AHL_VWP_RULES_PVT.Check_Currency_for_Costing
     (
       p_visit_id =>l_cost_price_rec.visit_id,
       x_currency_code => l_cost_price_rec.currency
     );

 -- Not to calculate cost if visit is in cancelled status
 IF l_visit_status <>'CANCELLED'  THEN

     -- To call to get cost if calculated
     AHL_VWP_COST_PVT.Calculate_WO_Cost
        (
          p_api_version => 1.0,
          p_init_msg_list => Fnd_Api.G_FALSE,
          p_commit=> Fnd_Api.G_FALSE,
          p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
          p_x_cost_price_rec  => l_cost_price_rec,
          x_return_status => x_return_status
         );

        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
          'AHL_VWP_COST_PVT.Calculate_WO_Cost API threw error : x_return_status : ' || x_return_status
        );
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
        END IF;

     -- To get visit cost calculated
     IF(l_cost_price_rec.Is_Cst_Struc_updated = 'N') AND (l_cost_price_rec.workorder_id IS NOT NULL) THEN

          AHL_VWP_COST_PVT.Calculate_Visit_Cost
          (
            p_visit_id          => l_cost_price_rec.visit_id,
            p_Session_id      => l_cost_price_rec.mr_session_id,
            x_Actual_cost     => l_cost_price_rec.actual_cost,
            x_Estimated_cost    => l_cost_price_rec.estimated_cost,
            x_return_status     => x_return_status
          );

          IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_exception,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
              'AHL_VWP_COST_PVT.Calculate_Visit_Cost API threw error : x_return_status : ' || x_return_status
            );
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
          END IF;

           -- To get profit and loss
           AHL_VWP_COST_PVT.Get_Profit_or_Loss
          (
            p_actual_price      => l_cost_price_rec.actual_price,
            p_estimated_price   => l_cost_price_rec.estimated_price,
            p_actual_cost     => l_cost_price_rec.actual_cost,
            p_estimated_cost    => l_cost_price_rec.estimated_cost,
            x_actual_profit     => l_cost_price_rec.actual_profit,
            x_estimated_profit  => l_cost_price_rec.estimated_profit,
            x_return_status     => x_return_status
           );
        END IF;

        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_exception,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details',
              'AHL_VWP_COST_PVT.Get_Profit_or_Loss API threw error : x_return_status : ' || x_return_status
            );
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
  END IF; -- status <> CANCELLED

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     p_x_cost_price_rec.outside_party_flag    := l_cost_price_rec.outside_party_flag;
     p_x_cost_price_rec.price_list_id         := l_cost_price_rec.price_list_id;
     p_x_cost_price_rec.price_list_name       := l_cost_price_rec.price_list_name;
     p_x_cost_price_rec.currency              := l_cost_price_rec.currency;

     --Bug#4302163 fix
     IF(l_cost_price_rec.Is_Cst_Struc_updated = 'N') THEN
         p_x_cost_price_rec.actual_price          := l_cost_price_rec.actual_price;
         p_x_cost_price_rec.estimated_price       := l_cost_price_rec.estimated_price;
     ELSE
         p_x_cost_price_rec.actual_price          := null;
         p_x_cost_price_rec.estimated_price       := null;
     END IF;

     p_x_cost_price_rec.actual_cost           := l_cost_price_rec.actual_cost;
     p_x_cost_price_rec.estimated_cost        := l_cost_price_rec.estimated_cost;
     p_x_cost_price_rec.actual_profit         := l_cost_price_rec.actual_profit;
     p_x_cost_price_rec.estimated_profit      := l_cost_price_rec.estimated_profit;
     p_x_cost_price_rec.Is_Cst_Struc_updated  := l_cost_price_rec.Is_Cst_Struc_updated;
     p_x_cost_price_rec.service_request_id    := l_cost_price_rec.service_request_id;
     p_x_cost_price_rec.customer_id           := l_cost_price_rec.customer_id;
     p_x_cost_price_rec.is_outside_pty_flag_updt := l_cost_price_rec.is_outside_pty_flag_updt;
     p_x_cost_price_rec.cost_session_id       := l_cost_price_rec.cost_session_id;
     p_x_cost_price_rec.mr_session_id         := l_cost_price_rec.mr_session_id;
     p_x_cost_price_rec.workorder_id          := l_cost_price_rec.workorder_id;
     p_x_cost_price_rec.visit_start_date      := l_cost_price_rec.visit_start_date;
     p_x_cost_price_rec.visit_end_date        := l_cost_price_rec.visit_end_date;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_cost_details.end',
      'At the end of PLSQL procedure'
    );
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO get_visit_cost_details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO get_visit_cost_details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO get_visit_cost_details;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'get_visit_cost_details',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END get_visit_cost_details;

--------------------------------------------------------------------------
-- Procedure to get visit cost details for a specific visit --
--------------------------------------------------------------------------
PROCEDURE update_visit_cost_details(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2)IS

-- Define local variables
    L_API_VERSION          CONSTANT NUMBER := 1.0;
    L_API_NAME             CONSTANT VARCHAR2(30) := 'update_visit_cost_details';
    L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

    l_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;
    l_outside_party_flag VARCHAR2(1);
    l_service_request_id NUMBER;
    l_visit_status_code VARCHAR2(30);
    l_start_date_time DATE;
    l_close_date_time DATE;
    l_exists VARCHAR2(1);
    l_error_msg_code VARCHAR2(240);
    l_valid_flag     VARCHAR2(1);

-- Define local cursors
    CURSOR visit_info_csr(p_visit_id IN NUMBER) IS
    SELECT outside_party_flag, service_request_id,
           status_code,start_date_time, close_date_time
    FROM ahl_visits_b
    WHERE visit_id = p_visit_id;

    CURSOR visit_tasks_csr(p_visit_id IN NUMBER) IS
    SELECT 'x' FROM ahl_visit_tasks_b
    WHERE visit_id = p_visit_id
    and nvl(status_code, 'x') <>'DELETED';

    CURSOR price_list_dates_csr(p_price_list_id IN NUMBER)IS
    SELECT start_date_active, end_date_active
    FROM qp_list_headers_v
    WHERE list_header_id = p_price_list_id;

    l_price_list_active_start_date DATE;
    l_price_list_active_end_date DATE;

    CURSOR update_visit_csr(p_visit_id IN NUMBER)IS
    SELECT * FROM ahl_visits_vl
    WHERE visit_id = p_visit_id
    FOR UPDATE OF object_version_number;
    visit_rec update_visit_csr%ROWTYPE;

BEGIN
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details.begin',
      'At the start of PLSQL procedure'
    );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT update_visit_cost_details;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_cost_price_rec := p_x_cost_price_rec;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
      'Got request for update visit cost details of Visit ID : ' || p_x_cost_price_rec.visit_id
    );
        fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
      'outside party flag : ' || p_x_cost_price_rec.outside_party_flag
    );
        fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
      'Price List Name  : ' || p_x_cost_price_rec.price_list_name
    );
     END IF;

     -- Make sure that visit id is present in the input
     IF(p_x_cost_price_rec.visit_id IS NULL OR p_x_cost_price_rec.visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --make sure outside party flag is valid
     IF (NVL(p_x_cost_price_rec.outside_party_flag,'N') NOT IN ('Y','N'))THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_OSP_INV');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
          'Input OSP Flag is invalid : ' || p_x_cost_price_rec.outside_party_flag
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     OPEN visit_info_csr(p_x_cost_price_rec.visit_id);
     FETCH visit_info_csr INTO l_outside_party_flag,
                               l_service_request_id,
                               l_visit_status_code,
                               l_start_date_time,
                               l_close_date_time;

     IF (visit_info_csr%NOTFOUND)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
          FND_MSG_PUB.ADD;
          CLOSE visit_info_csr;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
          'Visit id not found in ahl_visits_b table'
        );
          END IF;

     ELSIF (l_visit_status_code = 'CLOSED')THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT_UPDT_STS');
          FND_MSG_PUB.ADD;
          CLOSE visit_info_csr;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
          'Visit is closed so can not update outside party flag or price list'
        );
          END IF;

     ELSIF (l_service_request_id IS NULL)THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT_UPDT_NOSR');
          FND_MSG_PUB.ADD;
          CLOSE visit_info_csr;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
          'No service request is attached to visit so can not update outside party flag or price list'
        );
          END IF;

     ELSIF (NVL(l_cost_price_rec.outside_party_flag,'N') <> NVL(l_outside_party_flag,'N'))THEN
        CLOSE visit_info_csr;

        OPEN visit_tasks_csr(p_x_cost_price_rec.visit_id);
        FETCH visit_tasks_csr INTO l_exists;

        IF (visit_tasks_csr%FOUND)THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_OSP_FLAG_MOD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;

           IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
          'Can not modify outside party flag because tasks has already been created'
        );
           END IF;

        END IF;
        CLOSE visit_tasks_csr;
     ELSE
        CLOSE visit_info_csr;
     END IF;

     IF (p_module_type = 'JSP') THEN
        l_cost_price_rec.PRICE_LIST_ID := null;

       IF (l_cost_price_rec.outside_party_flag = 'Y' AND l_cost_price_rec.price_list_name IS NULL)
       THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_MAND');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
                'Price List is mandatory'
            );
             END IF;
             RAISE FND_API.G_EXC_ERROR;

       ELSIF (l_cost_price_rec.outside_party_flag = 'Y' AND l_cost_price_rec.price_list_name IS NOT NULL) THEN
             AHL_VWP_RULES_PVT.Check_Price_List_Name_Or_Id
             (
                p_visit_id    => l_cost_price_rec.visit_id,
                p_price_list_name => l_cost_price_rec.price_list_name,
                x_price_list_id => l_cost_price_rec.price_list_id,
                x_return_status => x_return_status
             );
             IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
                (
                 fnd_log.level_error,
                  'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
                 'AHL_VWP_RULES_PVT.Check_Price_List_Name_Or_Id API Threw error'
                );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       ELSIF(l_cost_price_rec.outside_party_flag = 'N' AND l_cost_price_rec.price_list_name IS NOT NULL)THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_OSP_VISIT_PR_LIST');
           -- Please select check box 'Visit for outside party' or remove price list from LOV.
           FND_MSG_PUB.ADD;
           IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
           (
              fnd_log.level_error,
                'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
                'Price List is mandatory'
           );
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF; -- Check p_module_type if 'JSP'

     -- validate validity of price list here(whether active for life of visit)
     -- fecth price list active start and end date
     IF l_cost_price_rec.price_list_id IS NOT NULL THEN
      OPEN price_list_dates_csr(l_cost_price_rec.price_list_id);
      FETCH price_list_dates_csr INTO l_price_list_active_start_date, l_price_list_active_end_date;
      CLOSE price_list_dates_csr; -- not found scenario is not possible at this step
     END IF;

  -- compare it with visit start and end dates
  IF(l_price_list_active_start_date IS NOT NULL OR l_price_list_active_end_date IS NOT NULL)THEN

    -- Check if the visit start date and visit planned end date if not null
    IF (l_start_date_time IS NOT NULL OR l_close_date_time IS NOT NULL ) THEN

        -- visit start date validation
        IF (l_start_date_time IS NOT NULL)THEN

           IF (TRUNC(l_price_list_active_start_date) > TRUNC(l_start_date_time)) OR
             (TRUNC(l_price_list_active_end_date) < TRUNC(l_start_date_time)) THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_INV_STR');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
              'Price List is not active on visit start date'
             );
             END IF;

          END IF;

       END IF; -- End of visit start_date check

       -- visit planned end date validation
       IF (l_close_date_time IS NOT NULL)THEN

           IF (TRUNC(l_price_list_active_start_date) > TRUNC(l_close_date_time)) OR
              (TRUNC(l_price_list_active_end_date) < TRUNC(l_close_date_time)) THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_INV_END');
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
              'Price List is not active on visit end date'
             );
             END IF;

          END IF;

        END IF;  -- End of visit planned end date check

      ELSE
      -- Check if the visit start date and visit planned end date are null
      -- then validate with current sysdate
         IF (TRUNC(l_price_list_active_start_date) > TRUNC(sysdate)) OR
              (TRUNC(l_price_list_active_end_date) < TRUNC(sysdate)) THEN

             FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PRICE_LIST_INV_SYS');
             -- CHANGE THIS MESSAGE TEST AND NAME TOO -- IMPORTANT
             FND_MSG_PUB.ADD;
             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details',
              'Price List is not active on current todays date'
             );
             END IF;

          END IF;

      END IF;  -- End of visit start_date and planned end date check

   END IF; -- End of price_list active_start_date and active_end_date check

     p_x_cost_price_rec.price_list_id := l_cost_price_rec.price_list_id;
     p_x_cost_price_rec.outside_party_flag := NVL(l_cost_price_rec.outside_party_flag,'N');

     -- update table.
     OPEN update_visit_csr(p_x_cost_price_rec.visit_id);
     FETCH update_visit_csr INTO visit_rec;
     CLOSE update_visit_csr;--not found condition not possible at this step

-- Post 11.5.10
-- Added Priority and Project Template
-- Reema Start

     AHL_VISITS_PKG.UPDATE_ROW
     (
        X_VISIT_ID => visit_rec.VISIT_ID,
        X_VISIT_NUMBER => visit_rec.VISIT_NUMBER,
        X_VISIT_TYPE_CODE => visit_rec.VISIT_TYPE_CODE,
        X_SIMULATION_PLAN_ID => visit_rec.SIMULATION_PLAN_ID,
        X_ITEM_INSTANCE_ID => visit_rec.ITEM_INSTANCE_ID,
        X_ITEM_ORGANIZATION_ID => visit_rec.ITEM_ORGANIZATION_ID,
        X_INVENTORY_ITEM_ID => visit_rec.INVENTORY_ITEM_ID,
        X_ASSO_PRIMARY_VISIT_ID => visit_rec.ASSO_PRIMARY_VISIT_ID,
        X_SIMULATION_DELETE_FLAG => visit_rec.SIMULATION_DELETE_FLAG,
        X_TEMPLATE_FLAG => visit_rec.TEMPLATE_FLAG,
        X_OUT_OF_SYNC_FLAG => visit_rec.OUT_OF_SYNC_FLAG,
        X_PROJECT_FLAG => visit_rec.PROJECT_FLAG,
        X_PROJECT_ID => visit_rec.PROJECT_ID,
        X_SERVICE_REQUEST_ID => visit_rec.SERVICE_REQUEST_ID,
        X_SPACE_CATEGORY_CODE => visit_rec.SPACE_CATEGORY_CODE,
        X_SCHEDULE_DESIGNATOR => visit_rec.SCHEDULE_DESIGNATOR,
        X_ATTRIBUTE_CATEGORY => visit_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => visit_rec.ATTRIBUTE1,
        X_ATTRIBUTE2 => visit_rec.ATTRIBUTE2,
        X_ATTRIBUTE3 => visit_rec.ATTRIBUTE3,
        X_ATTRIBUTE4 => visit_rec.ATTRIBUTE4,
        X_ATTRIBUTE5 => visit_rec.ATTRIBUTE5,
        X_ATTRIBUTE6 => visit_rec.ATTRIBUTE6,
        X_ATTRIBUTE7 => visit_rec.ATTRIBUTE7,
        X_ATTRIBUTE8 => visit_rec.ATTRIBUTE8,
        X_ATTRIBUTE9 => visit_rec.ATTRIBUTE9,
        X_ATTRIBUTE10 => visit_rec.ATTRIBUTE10,
        X_ATTRIBUTE11 => visit_rec.ATTRIBUTE11,
        X_ATTRIBUTE12 => visit_rec.ATTRIBUTE12,
        X_ATTRIBUTE13 => visit_rec.ATTRIBUTE13,
        X_ATTRIBUTE14 => visit_rec.ATTRIBUTE14,
        X_ATTRIBUTE15 => visit_rec.ATTRIBUTE15,
        X_OBJECT_VERSION_NUMBER => visit_rec.OBJECT_VERSION_NUMBER + 1,
        X_ORGANIZATION_ID => visit_rec.ORGANIZATION_ID,
        X_DEPARTMENT_ID => visit_rec.DEPARTMENT_ID,
        X_STATUS_CODE => visit_rec.STATUS_CODE,
        X_START_DATE_TIME => visit_rec.START_DATE_TIME,
        X_close_date_time => visit_rec.close_date_time,
        X_PRICE_LIST_ID => p_x_cost_price_rec.PRICE_LIST_ID,
        X_ESTIMATED_PRICE => visit_rec.ESTIMATED_PRICE,
        X_ACTUAL_PRICE => visit_rec.ACTUAL_PRICE,
        X_OUTSIDE_PARTY_FLAG => p_x_cost_price_rec.OUTSIDE_PARTY_FLAG,
        X_ANY_TASK_CHG_FLAG => visit_rec.ANY_TASK_CHG_FLAG,
        X_VISIT_NAME => visit_rec.VISIT_NAME,
        X_DESCRIPTION => visit_rec.DESCRIPTION,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.login_id,
        X_PRIORITY_CODE     => visit_rec.PRIORITY_CODE,
        X_PROJECT_TEMPLATE_ID  => visit_rec.PROJECT_TEMPLATE_ID,
        X_UNIT_SCHEDULE_ID => visit_rec.unit_schedule_id,
        X_INV_LOCATOR_ID  => visit_rec.INV_LOCATOR_ID --Added by sowsubra
     );

     -- Reema End

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.update_visit_cost_details.end',
      'At the end of PLSQL procedure'
    );
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO update_visit_cost_details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO update_visit_cost_details;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO update_visit_cost_details;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'update_visit_cost_details',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END update_visit_cost_details;

--------------------------------------------------------------------------
-- Procedure to estimate visit cost for a specific visit --
--------------------------------------------------------------------------
PROCEDURE estimate_visit_cost(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2)IS

-- Local Variables

-- Standard in/out parameters
l_api_name          VARCHAR2(30) := 'ESTIMATE_VISIT_COST ';
l_api_version         NUMBER       := 1.0;
l_num_rec             NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
l_commit VARCHAR2(30) := Fnd_Api.G_FALSE;

   l_release_visit_required     VARCHAR2(1) :='N';

   l_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
        fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost.begin',
      'At the start of PLSQL procedure'
    );
    END IF;

    -- Standard start of API savepoint
     SAVEPOINT estimate_visit_cost;

    -- Initialize message list if p_init_msg_list is set to TRUE

     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to check for call compatibility.
     IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
     THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_cost_price_rec:= p_x_cost_price_rec;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost',
      'Got request for estimating cost of Visit ID : ' || p_x_cost_price_rec.visit_id
    );

        fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost',
      'input mr session id : ' || p_x_cost_price_rec.mr_session_id
    );

        fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost',
      'input cost session id : ' || p_x_cost_price_rec.cost_session_id
    );
     END IF;

     -- make sure that visit id is present in the input

     IF(p_x_cost_price_rec.visit_id IS NULL OR p_x_cost_price_rec.visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     check_for_release_visit
     (
          p_visit_id                    =>p_x_cost_price_rec.visit_id,
          x_release_visit_required      =>l_release_visit_required
     );

    -- Release visit if required
    IF l_release_visit_required ='Y' THEN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string
      (
        fnd_log.level_procedure,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'Before calling ahl vwp proj prod pvt.release visit'
      );
    END IF;

      ahl_vwp_proj_prod_pvt.release_visit (
             p_api_version => l_api_version,
             p_init_msg_list => p_init_msg_list,
             p_commit => l_commit,
             p_validation_level => p_validation_level,
               p_module_type => 'CST',
             p_visit_id => l_cost_price_rec.visit_id,
             x_return_status => l_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
      (
        fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
         'After calling ahl vwp proj prod pvt.Release Visit task wo Return Status : '|| l_return_status
      );
    END IF;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
       END IF;

   END IF;  -- released required flag

     -- call AHL_VWP_COST_PVT.calculate_visit_cost

     AHL_VWP_COST_PVT.Estimate_WO_Cost
     (
          p_api_version => 1.0,
          p_init_msg_list => Fnd_Api.G_FALSE,
          p_commit=> Fnd_Api.G_FALSE,
          p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
          p_x_cost_price_rec  => l_cost_price_rec,
          x_return_status => x_return_status
     );

     IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost',
          'AHL_VWP_COST_PVT.Estimate_WO_Cost API threw error : x_return_status : ' || x_return_status
        );
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;

     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     p_x_cost_price_rec.Is_Cst_Struc_updated  := l_cost_price_rec.Is_Cst_Struc_updated;
     p_x_cost_price_rec.cost_session_id       := l_cost_price_rec.cost_session_id;
     p_x_cost_price_rec.mr_session_id         := l_cost_price_rec.mr_session_id;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_cost.end',
      'At the end of PLSQL procedure'
    );
     END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN

   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO estimate_visit_cost;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO estimate_visit_cost;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO estimate_visit_cost;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'estimate_visit_cost',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END estimate_visit_cost;

--------------------------------------------------------------------------
-- Procedure to estimate price for a specific SR --
--bug fix #4181411
-- yazhou 18-Feb-2005
--------------------------------------------------------------------------
PROCEDURE Estimate_SR_Price(
    p_x_cost_price_rec     IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2)
IS

  -- Get all the root MR in the SR

    CURSOR sr_summary_tasks_csr(p_task_id IN NUMBER)IS
      SELECT visit_task_id FROM ahl_visit_tasks_b VST
          WHERE  VST.task_type_code = 'SUMMARY'
      AND VST.originating_task_id =p_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      AND VST.mr_id IS NOT NULL;

  -- Get other planned tasks in the SR

    CURSOR sr_other_tasks_csr(p_task_id IN NUMBER)IS
      SELECT visit_task_id, start_date_time, end_date_time FROM ahl_visit_tasks_b VST
          WHERE  VST.task_type_code = 'PLANNED'
      AND VST.originating_task_id =p_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X');

    --Get min(start_time), max(end_time) for summary tasks
    CURSOR get_summary_task_times_csr(p_task_id IN NUMBER)IS
      SELECT min(start_date_time), max(end_date_time)
      FROM ahl_visit_tasks_b VST
      START WITH visit_task_id  = p_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      CONNECT BY originating_task_id = PRIOR visit_task_id;

    l_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;
    l_temp_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;

    l_actual_price       NUMBER;
    l_estimated_price    NUMBER;

    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.Estimate_SR_Price.begin',
      'At the start of PLSQL procedure'
    );
   END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_cost_price_rec:= p_x_cost_price_rec;

     -- Initialize Price variables
     l_cost_price_rec.actual_price := 0;
     l_cost_price_rec.estimated_price := 0;
     l_actual_price := 0;
     l_estimated_price := 0;

    -- process summary tasks
     FOR sr_summary_tasks_rec IN sr_summary_tasks_csr(l_cost_price_rec.visit_task_id) LOOP


                OPEN get_summary_task_times_csr(sr_summary_tasks_rec.visit_task_id);
                FETCH get_summary_task_times_csr INTO l_cost_price_rec.Task_Start_Date,
                                                    l_cost_price_rec.Task_END_Date;
                CLOSE get_summary_task_times_csr;

            --initialize input

            l_temp_cost_price_rec.visit_task_id := sr_summary_tasks_rec.visit_task_id;

            l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

            l_temp_cost_price_rec.task_start_date := l_cost_price_rec.Task_Start_Date;

            l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

            l_temp_cost_price_rec.actual_price := NULL;

            l_temp_cost_price_rec.estimated_price := NULL;

            l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

            l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;


            -- call api to estimate price for this summary task

            AHL_VWP_MR_CST_PR_PVT.Estimate_MR_Price
            (
               p_api_version          => 1.0,
               p_init_msg_list        => Fnd_Api.g_false,
               p_commit               => Fnd_Api.g_false,
               p_validation_level     => Fnd_Api.g_valid_level_full,
               p_module_type          => 'VST',
               p_x_cost_price_rec     => l_temp_cost_price_rec,
               x_return_status         => x_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data
            );

            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.Estimate_SR_Price',
              'AHL_VWP_MR_CST_PR_PVT.Estimate_MR_Price API Threw error'
             );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

          IF(l_temp_cost_price_rec.actual_price IS NOT NULL) THEN
              l_actual_price := l_actual_price + l_temp_cost_price_rec.actual_price;
            END IF;

            IF(l_temp_cost_price_rec.estimated_price IS NOT NULL) THEN
              l_estimated_price := l_estimated_price + l_temp_cost_price_rec.estimated_price;
            END IF;

     END LOOP;


     -- process other tasks

     FOR sr_other_tasks_rec IN sr_other_tasks_csr(l_cost_price_rec.visit_task_id) LOOP


                --bug fix #4181411
                -- yazhou 18-Feb-2005

                l_cost_price_rec.Task_Start_Date := sr_other_tasks_rec.start_date_time;
                l_cost_price_rec.Task_End_Date := sr_other_tasks_rec.end_date_time;


            --initialize input

            l_temp_cost_price_rec.visit_task_id := sr_other_tasks_rec.visit_task_id;

            l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

            l_temp_cost_price_rec.task_start_date := l_cost_price_rec.Task_Start_Date;

            l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

            l_temp_cost_price_rec.actual_price := NULL;

            l_temp_cost_price_rec.estimated_price := NULL;

            l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

            l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;


            -- call api to estimate price for this summary task

            AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price
            (
               p_api_version          => 1.0,
               p_init_msg_list        => Fnd_Api.g_false,
               p_commit               => Fnd_Api.g_false,
               p_validation_level     => Fnd_Api.g_valid_level_full,
               p_module_type          => 'VST',
               p_x_cost_price_rec     => l_temp_cost_price_rec,
               x_return_status         => x_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data
            );

            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_SR_price',
              'AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price API Threw error'
             );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF(l_temp_cost_price_rec.actual_price IS NOT NULL) THEN

              l_actual_price := l_actual_price + l_temp_cost_price_rec.actual_price;

            END IF;

            IF(l_temp_cost_price_rec.estimated_price IS NOT NULL) THEN

              l_estimated_price := l_estimated_price + l_temp_cost_price_rec.estimated_price;

            END IF;

     END LOOP;


     --update task table with SR price
                        Update AHL_VISIT_TASKS_B
                        set actual_price=l_actual_price,
                            estimated_price=l_estimated_price
                        where visit_task_id=l_cost_price_rec.visit_task_id;


     -- assign output parameters

        p_x_cost_price_rec.estimated_price:=l_estimated_price;
        p_x_cost_price_rec.actual_price:=l_actual_price;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.Estimate_SR_Price.end',
      'At the end of PLSQL procedure'
    );
   END IF;
END  Estimate_SR_Price;

--------------------------------------------------------------------------
-- Procedure to estimate visit price for a specific visit --
--------------------------------------------------------------------------

PROCEDURE estimate_visit_price(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2)
IS

    l_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;
    l_temp_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;


    l_job_status_code    VARCHAR2(30);
    l_job_status_meaning VARCHAR2(80);
    l_actual_price       NUMBER;
    l_estimated_price    NUMBER;
    l_z                     number:=0;
    l_flag              varchar2(1);
    l_visit_task_id     AHL_VISIT_TASKS_B.visit_task_id%TYPE;

-- Standard in/out parameters
    l_api_name          VARCHAR2(30) := 'ESTIMATE_VISIT_PRICE ';
    l_msg_data              VARCHAR2(2000);
    l_api_version         NUMBER       := 1.0;
    l_num_rec             NUMBER;
    l_msg_count             NUMBER;
    l_return_status         VARCHAR2(1);
    l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
    l_commit                VARCHAR2(30) := Fnd_Api.G_FALSE;
--
    CURSOR visit_info_csr(p_visit_id IN NUMBER) IS
    Select VISIT_ID,
       PRICE_LIST_ID,
       SERVICE_REQUEST_ID,
       OUTSIDE_PARTY_FLAG,
       ORGANIZATION_ID,
       any_task_chg_flag
    From ahl_visits_b
    where visit_id=p_visit_id;

    l_visit_rec              visit_info_csr%rowtype;

    CURSOR customer_id_csr(p_service_request_id IN NUMBER)IS
      SELECT customer_id FROM cs_incidents_all
           WHERE incident_id = p_service_request_id;

  -- Get all the root MR in the visit

    CURSOR summary_tasks_csr(p_visit_id IN NUMBER)IS
      SELECT visit_task_id FROM ahl_visit_tasks_b VST
          WHERE VST.visit_id = p_visit_id
      AND VST.task_type_code = 'SUMMARY'
      AND VST.originating_task_id IS NULL
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      AND VST.mr_id IS NOT NULL;

    --bug fix #4181411
    -- yazhou 18-Feb-2005
    -- Get all the root SR in the visit

    CURSOR SR_tasks_csr(p_visit_id IN NUMBER)IS
      SELECT visit_task_id FROM ahl_visit_tasks_b VST
          WHERE VST.visit_id = p_visit_id
      AND VST.task_type_code = 'SUMMARY'
      AND VST.originating_task_id IS NULL
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      AND VST.mr_id IS NULL
      AND VST.unit_effectivity_id IS NOT NULL;

    --Get min(start_time), max(end_time) for summary tasks
 CURSOR get_summary_task_times_csr(p_task_id IN NUMBER)IS
      SELECT min(start_date_time), max(end_date_time)
      FROM ahl_visit_tasks_b VST
      START WITH visit_task_id  = p_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      CONNECT BY originating_task_id = PRIOR visit_task_id;

    --bug fix #4181411
    -- yazhou 18-Feb-2005
    -- Get all the unassociated tasks

   CURSOR other_tasks_csr(p_visit_id IN NUMBER)IS
     SELECT visit_task_id, start_date_time, end_date_time FROM ahl_visit_tasks_b VST
         WHERE VST.visit_id = p_visit_id
     AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
     AND VST.task_type_code = 'UNASSOCIATED';


   CURSOR update_visit_csr(p_visit_id IN NUMBER)IS
     SELECT * FROM ahl_visits_vl
      WHERE visit_id = p_visit_id
    FOR UPDATE OF object_version_number;

    visit_rec update_visit_csr%ROWTYPE;
    l_error_msg_code VARCHAR2(240);
    l_valid_flag     VARCHAR2(1);

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price.begin',
      'At the start of PLSQL procedure'
    );
   END IF;

     -- Standard start of API savepoint
     SAVEPOINT estimate_visit_price;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to check for call compatibility.
     IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
     THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_cost_price_rec:= p_x_cost_price_rec;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
      'Got request for estimating of Visit ID : ' || p_x_cost_price_rec.visit_id
    );
     END IF;

     -- make sure that visit id is present in the input

     IF(p_x_cost_price_rec.visit_id IS NULL OR p_x_cost_price_rec.visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- get outside party flag
     OPEN visit_info_csr(p_x_cost_price_rec.visit_id);
     FETCH visit_info_csr INTO l_visit_rec;

     IF(visit_info_csr%NOTFOUND)THEN

        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
        FND_MSG_PUB.ADD;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'visit info not found for input visit id'
        );
        END IF;
        CLOSE visit_info_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSE
        l_cost_price_rec.outside_party_flag := NVL(l_visit_rec.outside_party_flag,'N');
     END IF;
     CLOSE visit_info_csr;

     -- price estimation valid or not
     IF(l_cost_price_rec.outside_party_flag <> 'Y')THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_PR_EST');
        FND_MSG_PUB.ADD;

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'Price estimation is restricted to outside party visit only '
        );
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'Before release_visit cursor'
        );
     END IF;

  --Call estimate task cost
  Estimate_Visit_Cost (
      p_api_version => l_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => l_commit,
      p_validation_level => p_validation_level,
      p_module_type => p_module_type,

      p_x_cost_price_rec => l_cost_price_rec,

      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);


  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string
     (
      fnd_log.level_procedure,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
      'After calling ahl vwp task cost pvt.Estimate Task cost Return Status : '|| l_return_status
      );
  END IF;

-- Check Error Message stack.
    if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
     l_msg_count := FND_MSG_PUB.count_msg;
     IF l_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;

--Assign the out variable
    p_x_cost_price_rec.cost_session_id := l_cost_price_rec.cost_session_id;
    p_x_cost_price_rec.mr_session_id := l_cost_price_rec.mr_session_id;
    p_x_cost_price_rec.Is_Cst_Struc_updated := l_cost_price_rec.Is_Cst_Struc_updated;


--- Populate pricing attributes

     -- find out customer id
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'Before customer cursor'
        );
       END IF;

     OPEN customer_id_csr(l_visit_rec.service_request_id);
     FETCH customer_id_csr INTO l_cost_price_rec.customer_id;

     IF(customer_id_csr%NOTFOUND)THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_SRVREQ_NOCUST');
        FND_MSG_PUB.ADD;

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'Customer id not found for service request'
        );
        END IF;
        CLOSE customer_id_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     CLOSE customer_id_csr;

-- Populate currency code
   ahl_vwp_rules_pvt.check_currency_for_costing
   (
      p_visit_id => l_visit_rec.visit_id,
      x_currency_code => l_cost_price_rec.currency);

-- Check if currency value is null
   IF l_cost_price_rec.currency IS NULL THEN
          FND_MESSAGE.Set_Name(G_PKG_NAME,'AHL_VWP_CST_NO_CURRENCY');
          FND_MSG_PUB.ADD;

          IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
              fnd_log.level_error,
              'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
              'No curency is defined for the organization of the visit'
          );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
   END IF;


-- Get the visit price list if not passed
   IF (l_visit_rec.price_list_id IS NULL OR
     l_visit_rec.price_list_id = FND_API.G_MISS_NUM ) THEN

      FND_MESSAGE.set_name( 'AHL','AHL_VWP_PRICE_LIST_INVALID' );
      FND_MSG_PUB.add;

    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
    fnd_log.level_error,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Price list not found for Visit'
    );
    END IF;
  RAISE FND_API.G_EXC_ERROR;
END IF;

  l_cost_price_rec.PRICE_LIST_ID:=l_visit_rec.price_list_id;
  l_cost_price_rec.Organization_Id:=l_visit_rec.organization_id;


IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN

    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Customer Id : ' || l_cost_price_rec.customer_id
    );

    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Visit Id : ' || l_cost_price_rec.visit_id
    );

    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Currency : ' || l_cost_price_rec.currency
    );

    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Price List Id : ' || l_cost_price_rec.PRICE_LIST_ID
    );

    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Organization ID : ' || l_cost_price_rec.Organization_Id
    );

END IF;



   -- Initialize Price variables
     l_cost_price_rec.actual_price := 0;
     l_cost_price_rec.estimated_price := 0;
     l_actual_price := 0;
     l_estimated_price := 0;


   --- Check job status

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': ',
             'before check job status');
         END IF;

        AHL_VWP_RULES_PVT.Check_Job_Status
        (
            p_id    => l_cost_price_rec.visit_id,
            p_is_task_flag => 'N',
            x_status_code  => l_job_status_code,
            x_status_meaning => l_job_status_meaning
        );

  IF (l_job_status_code is NULL) THEN
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  END IF;


     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
          'Before Summary TAsk cursor '
        );
      END IF;

    -- process summary tasks
     FOR summary_tasks_rec IN summary_tasks_csr(l_visit_rec.visit_id) LOOP


                l_visit_task_id := summary_tasks_rec.visit_task_id;
                OPEN get_summary_task_times_csr(l_visit_task_id);
                FETCH get_summary_task_times_csr INTO l_cost_price_rec.Task_Start_Date,
                                                    l_cost_price_rec.Task_END_Date;
                CLOSE get_summary_task_times_csr;

            --initialize input

            l_temp_cost_price_rec.visit_task_id := summary_tasks_rec.visit_task_id;

            l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

            l_temp_cost_price_rec.task_start_date := l_cost_price_rec.Task_Start_Date;

            l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

            l_temp_cost_price_rec.actual_price := NULL;

            l_temp_cost_price_rec.estimated_price := NULL;

            l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

            l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;


            -- call api to estimate price for this summary task

            AHL_VWP_MR_CST_PR_PVT.Estimate_MR_Price
            (
               p_api_version          => 1.0,
               p_init_msg_list        => Fnd_Api.g_false,
               p_commit               => Fnd_Api.g_false,
               p_validation_level     => Fnd_Api.g_valid_level_full,
               p_module_type          => 'VST',
               p_x_cost_price_rec     => l_temp_cost_price_rec,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data
            );

            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
              'AHL_VWP_MR_CST_PR_PVT.Estimate_MR_Price API Threw error'
             );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

          IF(l_temp_cost_price_rec.actual_price IS NOT NULL) THEN
              l_actual_price := l_actual_price + l_temp_cost_price_rec.actual_price;
            END IF;

            IF(l_temp_cost_price_rec.estimated_price IS NOT NULL) THEN
              l_estimated_price := l_estimated_price + l_temp_cost_price_rec.estimated_price;
            END IF;

     END LOOP;

    --bug fix #4181411
    -- yazhou 18-Feb-2005

    -- process SR tasks
     FOR SR_tasks_rec IN SR_tasks_csr(l_visit_rec.visit_id) LOOP

            --initialize input

            l_temp_cost_price_rec.visit_task_id := SR_tasks_rec.visit_task_id;

            l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

--            l_temp_cost_price_rec.task_start_date := l_cost_price_rec.Task_Start_Date;

            l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

            l_temp_cost_price_rec.actual_price := NULL;

            l_temp_cost_price_rec.estimated_price := NULL;

            l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

            l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;


            -- call api to estimate price for this SR

            Estimate_SR_Price
            (
               p_x_cost_price_rec     => l_temp_cost_price_rec,
               x_return_status         => x_return_status
            );

            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
              'Estimate_SR_Price API Threw error'
             );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

          IF(l_temp_cost_price_rec.actual_price IS NOT NULL) THEN
              l_actual_price := l_actual_price + l_temp_cost_price_rec.actual_price;
            END IF;

            IF(l_temp_cost_price_rec.estimated_price IS NOT NULL) THEN
              l_estimated_price := l_estimated_price + l_temp_cost_price_rec.estimated_price;
            END IF;

     END LOOP;


     -- process other tasks

     FOR other_tasks_rec IN other_tasks_csr(p_x_cost_price_rec.visit_id) LOOP


                --bug fix #4181411
                -- yazhou 18-Feb-2005

                l_cost_price_rec.Task_Start_Date := other_tasks_rec.start_date_time;
                l_cost_price_rec.Task_End_Date := other_tasks_rec.end_date_time;


            --initialize input

            l_temp_cost_price_rec.visit_task_id := other_tasks_rec.visit_task_id;

            l_temp_cost_price_rec.currency := l_cost_price_rec.currency;

            l_temp_cost_price_rec.task_start_date := l_cost_price_rec.Task_Start_Date;

            l_temp_cost_price_rec.customer_id := l_cost_price_rec.customer_id;

            l_temp_cost_price_rec.actual_price := NULL;

            l_temp_cost_price_rec.estimated_price := NULL;

            l_temp_cost_price_rec.PRICE_LIST_ID:=l_cost_price_rec.price_list_id;

            l_temp_cost_price_rec.Organization_Id:=l_cost_price_rec.organization_id;


            -- call api to estimate price for this summary task

            AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price
            (
               p_api_version          => 1.0,
               p_init_msg_list        => Fnd_Api.g_false,
               p_commit               => Fnd_Api.g_false,
               p_validation_level     => Fnd_Api.g_valid_level_full,
               p_module_type          => 'VST',
               p_x_cost_price_rec     => l_temp_cost_price_rec,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data
            );

            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

             IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price',
              'AHL_VWP_TASK_CST_PR_PVT.Estimate_Task_Price API Threw error'
             );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF(l_temp_cost_price_rec.actual_price IS NOT NULL) THEN

              l_actual_price := l_actual_price + l_temp_cost_price_rec.actual_price;

            END IF;

            IF(l_temp_cost_price_rec.estimated_price IS NOT NULL) THEN

              l_estimated_price := l_estimated_price + l_temp_cost_price_rec.estimated_price;

            END IF;

     END LOOP;

     --update the latest price info.

     OPEN update_visit_csr(p_x_cost_price_rec.visit_id);
     FETCH update_visit_csr INTO visit_rec;
     CLOSE update_visit_csr;--not found condition not possible at this step

-- Post 11.5.10
-- Added Priority and Project template
-- Reema Start

     AHL_VISITS_PKG.UPDATE_ROW
     (
        X_VISIT_ID => visit_rec.VISIT_ID,

        X_VISIT_NUMBER => visit_rec.VISIT_NUMBER,

        X_VISIT_TYPE_CODE => visit_rec.VISIT_TYPE_CODE,

        X_SIMULATION_PLAN_ID => visit_rec.SIMULATION_PLAN_ID,

        X_ITEM_INSTANCE_ID => visit_rec.ITEM_INSTANCE_ID,

        X_ITEM_ORGANIZATION_ID => visit_rec.ITEM_ORGANIZATION_ID,

        X_INVENTORY_ITEM_ID => visit_rec.INVENTORY_ITEM_ID,

        X_ASSO_PRIMARY_VISIT_ID => visit_rec.ASSO_PRIMARY_VISIT_ID,

        X_SIMULATION_DELETE_FLAG => visit_rec.SIMULATION_DELETE_FLAG,

        X_TEMPLATE_FLAG => visit_rec.TEMPLATE_FLAG,

        X_OUT_OF_SYNC_FLAG => visit_rec.OUT_OF_SYNC_FLAG,

        X_PROJECT_FLAG => visit_rec.PROJECT_FLAG,

        X_PROJECT_ID => visit_rec.PROJECT_ID,

        X_SERVICE_REQUEST_ID => visit_rec.SERVICE_REQUEST_ID,

        X_SPACE_CATEGORY_CODE => visit_rec.SPACE_CATEGORY_CODE,

        X_SCHEDULE_DESIGNATOR => visit_rec.SCHEDULE_DESIGNATOR,

        X_ATTRIBUTE_CATEGORY => visit_rec.ATTRIBUTE_CATEGORY,

        X_ATTRIBUTE1 => visit_rec.ATTRIBUTE1,

        X_ATTRIBUTE2 => visit_rec.ATTRIBUTE2,

        X_ATTRIBUTE3 => visit_rec.ATTRIBUTE3,

        X_ATTRIBUTE4 => visit_rec.ATTRIBUTE4,

        X_ATTRIBUTE5 => visit_rec.ATTRIBUTE5,

        X_ATTRIBUTE6 => visit_rec.ATTRIBUTE6,

        X_ATTRIBUTE7 => visit_rec.ATTRIBUTE7,

        X_ATTRIBUTE8 => visit_rec.ATTRIBUTE8,

        X_ATTRIBUTE9 => visit_rec.ATTRIBUTE9,

        X_ATTRIBUTE10 => visit_rec.ATTRIBUTE10,

        X_ATTRIBUTE11 => visit_rec.ATTRIBUTE11,

        X_ATTRIBUTE12 => visit_rec.ATTRIBUTE12,

        X_ATTRIBUTE13 => visit_rec.ATTRIBUTE13,

        X_ATTRIBUTE14 => visit_rec.ATTRIBUTE14,

        X_ATTRIBUTE15 => visit_rec.ATTRIBUTE15,

        X_OBJECT_VERSION_NUMBER => visit_rec.OBJECT_VERSION_NUMBER + 1,

        X_ORGANIZATION_ID => visit_rec.ORGANIZATION_ID,

        X_DEPARTMENT_ID => visit_rec.DEPARTMENT_ID,

        X_STATUS_CODE => visit_rec.STATUS_CODE,

        X_START_DATE_TIME => visit_rec.START_DATE_TIME,

        X_close_date_time => visit_rec.close_date_time,

        X_PRICE_LIST_ID => visit_rec.PRICE_LIST_ID,

        X_ESTIMATED_PRICE => l_estimated_price,

        X_ACTUAL_PRICE => l_actual_price,

        X_OUTSIDE_PARTY_FLAG => visit_rec.OUTSIDE_PARTY_FLAG,

        X_ANY_TASK_CHG_FLAG => visit_rec.ANY_TASK_CHG_FLAG,

        X_VISIT_NAME => visit_rec.VISIT_NAME,

        X_DESCRIPTION => visit_rec.DESCRIPTION,

        X_LAST_UPDATE_DATE => SYSDATE,

        X_LAST_UPDATED_BY => fnd_global.user_id,

        X_LAST_UPDATE_LOGIN => fnd_global.login_id,

        X_PRIORITY_CODE     => visit_rec.PRIORITY_CODE,
        X_PROJECT_TEMPLATE_ID  => visit_rec.PROJECT_TEMPLATE_ID,
        X_UNIT_SCHEDULE_ID => visit_rec.unit_schedule_id,
        X_INV_LOCATOR_ID         => visit_rec.INV_LOCATOR_ID --Added by sowsubra
     );

-- Reema End

     p_x_cost_price_rec.actual_price := l_actual_price;

     p_x_cost_price_rec.estimated_price := l_estimated_price;


     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;

     IF x_msg_count > 0 THEN

       RAISE  FND_API.G_EXC_ERROR;

     END IF;



     -- Standard check of p_commit

     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.estimate_visit_price.end',
      'At the end of PLSQL procedure'
    );
     END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN

   x_return_status := FND_API.G_RET_STS_ERROR;

   ROLLBACK TO estimate_visit_price;

   FND_MSG_PUB.count_and_get( p_count => x_msg_count,

                              p_data  => x_msg_data,

                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   ROLLBACK TO estimate_visit_price;

   FND_MSG_PUB.count_and_get( p_count => x_msg_count,

                              p_data  => x_msg_data,

                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ROLLBACK TO estimate_visit_price;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,

                               p_procedure_name => 'estimate_visit_price',

                               p_error_text     => SUBSTR(SQLERRM,1,500));

    END IF;

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,

                               p_data  => x_msg_data,

                               p_encoded => fnd_api.g_false);

END estimate_visit_price;

--------------------------------------------------------------------------
-- Procedure to take a price snapshot for a specific visit --
--------------------------------------------------------------------------
PROCEDURE create_price_snapshot(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_visit_id              IN             NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2)IS


    CURSOR other_tasks_snapshot_csr(p_visit_id IN NUMBER) IS

    SELECT VT.visit_task_id, VT.mr_id,VT.estimated_price,VT.actual_price,VT.visit_task_number, V.visit_number
    FROM ahl_visit_tasks_b VT, ahl_visits_b V
    WHERE VT.VISIT_ID = V.VISIT_ID
    AND NOT (task_type_code = 'SUMMARY' AND mr_id IS NULL)
    AND V.visit_id = p_visit_id
    AND nvl(VT.status_code,'x') <> 'DELETED'
    and VT.visit_task_id not in (
      select VST.visit_task_id
      from ahl_visit_tasks_b VST,
      AHL_MR_HEADERS_APP_V mr
      where vst.mr_id = mr.mr_header_id
      and vst.visit_id =p_visit_id
      AND nvl(VST.status_code,'x') <> 'DELETED'
      and mr.billing_item_id is not null
      and vst.task_type_code <>'SUMMARY');

    l_snapshot_id NUMBER;
    l_snapshot_number NUMBER;
    L_API_VERSION          CONSTANT NUMBER := 1.0;
    L_API_NAME             CONSTANT VARCHAR2(30) := 'create_price_snapshot';
    L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_price_snapshot.begin',
      'At the start of PLSQL procedure'
    );
    END IF;

     -- Standard start of API savepoint

     SAVEPOINT create_price_snapshot;

     -- Initialize message list if p_init_msg_list is set to TRUE

     IF FND_API.To_Boolean( p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to check for call compatibility.
     IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
     THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
        'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_price_snapshot',
      'Got request for tasking a price snapshot of Visit ID : ' || p_visit_id
    );
     END IF;

     -- make sure that visit id is present in the input

     IF(p_visit_id IS NULL OR p_visit_id = FND_API.G_MISS_NUM) THEN

        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_price_snapshot',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     -- get a snapshot number for ahl_snapshot_number_s for the whole set
     SELECT AHL_SNAPSHOTS_S.NEXTVAL INTO l_snapshot_number FROM DUAL;

     FOR other_tasks_rec IN other_tasks_snapshot_csr(p_visit_id) LOOP

       IF(other_tasks_rec.actual_price IS NULL OR other_tasks_rec.estimated_price IS NULL)THEN

         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_SNAP_PRC_MISS');
         FND_MESSAGE.Set_Token('VISIT_TASK_NUMBER',other_tasks_rec.visit_task_number);
         FND_MESSAGE.Set_Token('VISIT_NUMBER',other_tasks_rec.visit_number);
         FND_MSG_PUB.ADD;

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_price_snapshot',
              'Price not found for task id : ' || other_tasks_rec.visit_task_id
         );
         END IF;
         EXIT;

       ELSE

         --get sequence
         SELECT AHL_SNAPSHOTS_S.NEXTVAL INTO l_snapshot_id FROM DUAL;

         -- take snapshot now
         AHL_SNAPSHOTS_PKG.INSERT_ROW
          (
            X_SNAPSHOT_ID           => l_snapshot_id,

            X_OBJECT_VERSION_NUMBER => 1,

            X_SNAPSHOT_NUMBER       => l_snapshot_number,

            X_LAST_UPDATE_DATE      => SYSDATE,

            X_LAST_UPDATED_BY       => fnd_global.user_id,

            X_CREATION_DATE         => SYSDATE,

            X_CREATED_BY            => fnd_global.user_id,

            X_LAST_UPDATE_LOGIN     => fnd_global.login_id,

            X_VISIT_ID              => p_visit_id,

            X_VISIT_TASK_ID         => other_tasks_rec.visit_task_id,

            X_MR_ID                 => other_tasks_rec.mr_id,

            X_ESTIMATED_PRICE       => other_tasks_rec.estimated_price,

            X_ACTUAL_PRICE          => other_tasks_rec.actual_price,

            X_ESTIMATED_COST        => null,

            X_ACTUAL_COST           => null,

            X_ATTRIBUTE_CATEGORY    => null,

            X_ATTRIBUTE1            => null,

            X_ATTRIBUTE2            => null,

            X_ATTRIBUTE3            => null,

            X_ATTRIBUTE4            => null,

            X_ATTRIBUTE5            => null,

            X_ATTRIBUTE6            => null,

            X_ATTRIBUTE7            => null,

            X_ATTRIBUTE8            => null,

            X_ATTRIBUTE9            => null,

            X_ATTRIBUTE10           => null,

            X_ATTRIBUTE11           => null,

            X_ATTRIBUTE12           => null,

            X_ATTRIBUTE13           => null,

            X_ATTRIBUTE14           => null,

            X_ATTRIBUTE15           => null

          );

       END IF;

     END LOOP;



     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_price_snapshot.end',
      'At the end of PLSQL procedure'
    );
     END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN

   x_return_status := FND_API.G_RET_STS_ERROR;

   ROLLBACK TO create_price_snapshot;

   FND_MSG_PUB.count_and_get( p_count => x_msg_count,

                              p_data  => x_msg_data,

                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   ROLLBACK TO create_price_snapshot;

   FND_MSG_PUB.count_and_get( p_count => x_msg_count,

                              p_data  => x_msg_data,

                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ROLLBACK TO create_price_snapshot;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,

                               p_procedure_name => 'create_price_snapshot',

                               p_error_text     => SUBSTR(SQLERRM,1,500));

    END IF;

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,

                               p_data  => x_msg_data,

                               p_encoded => fnd_api.g_false);

END create_price_snapshot;

--------------------------------------------------------------------------
-- Procedure to take a cost snapshot for a specific visit --
--------------------------------------------------------------------------
PROCEDURE create_cost_snapshot(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2)IS

    l_cost_price_rec AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type;

    CURSOR summary_tasks_snapshot_csr(p_visit_id IN NUMBER) IS
    SELECT visit_task_id, mr_id FROM ahl_visit_tasks_vl
    WHERE mr_id IS NULL
    AND task_type_code = 'SUMMARY'
    AND visit_id = p_visit_id
    AND nvl(status_code,'x') <> 'DELETED';

    CURSOR other_tasks_snapshot_csr(p_visit_id IN NUMBER) IS
    SELECT visit_task_id, mr_id FROM ahl_visit_tasks_vl
    WHERE visit_id = p_visit_id
    AND nvl(status_code,'x') <> 'DELETED'
    AND NOT (task_type_code = 'SUMMARY' AND mr_id IS NULL);



    CURSOR workorder_csr(p_visit_task_id IN NUMBER)IS
--    SELECT workorder_id, wip_entity_id FROM ahl_all_workorders_v
--    WHERE visit_task_id = p_visit_task_id;
--    Changed for changing the perf bug# 4919518
      SELECT   workorder_id,wip_entity_id
      FROM     ahl_workorders
      WHERE    visit_task_id =  p_visit_task_id
      AND      STATUS_CODE <> '22';

    l_workorder_id      NUMBER;
    l_wip_entity_id     NUMBER;
    l_actual_cost       NUMBER;
    l_estimated_cost    NUMBER;
    l_snapshot_id       NUMBER;
    l_snapshot_number   NUMBER;

    L_API_VERSION          CONSTANT NUMBER := 1.0;
    L_API_NAME             CONSTANT VARCHAR2(30) := 'create_cost_snapshot';
    L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

BEGIN
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot.begin',
      'At the start of PLSQL procedure'
    );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT create_cost_snapshot;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to check for call compatibility.
     IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
     THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_cost_price_rec := p_x_cost_price_rec;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot',
      'Got request for tasking a cost snapshot of Visit ID : ' || p_x_cost_price_rec.visit_id
    );
     END IF;

     -- make sure that visit id is present in the input
     IF(p_x_cost_price_rec.visit_id IS NULL OR p_x_cost_price_rec.visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- get a snapshot number for ahl_snapshot_number_s for the whole set
     SELECT AHL_SNAPSHOTS_S.NEXTVAL INTO l_snapshot_number FROM DUAL;

     -- call calculate workorder cost
     AHL_VWP_COST_PVT.Estimate_WO_Cost
     (
          p_api_version => 1.0,
          p_init_msg_list => Fnd_Api.G_FALSE,
          p_commit=> Fnd_Api.G_FALSE,
          p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
          p_x_cost_price_rec  => l_cost_price_rec,
          x_return_status => x_return_status
     );

     IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_exception,
          'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot',
          'AHL_VWP_COST_PVT.Estimate_WO_Cost API threw error : x_return_status : ' || x_return_status
        );
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- take a snapshot of manually created summary tasks
     FOR summary_tasks_rec IN summary_tasks_snapshot_csr(p_x_cost_price_rec.visit_id) LOOP
        OPEN workorder_csr(summary_tasks_rec.visit_task_id);
        FETCH workorder_csr INTO l_workorder_id, l_wip_entity_id;

        IF(workorder_csr%FOUND)THEN
          AHL_VWP_COST_PVT.Calculate_Task_Cost
          (
            p_visit_task_id    => summary_tasks_rec.visit_task_id,
            p_session_id     => p_x_cost_price_rec.mr_session_id,
            x_Actual_cost    => l_actual_cost,
            x_Estimated_cost   => l_estimated_cost,
            x_return_status    => x_return_status
          );

          IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_CALC_TCOST_ERR');
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot',
              'AHL_VWP_COST_PVT.Calculate_Task_Cost API threw error :summary: x_return_status : ' || x_return_status
            );
            END IF;
            CLOSE workorder_csr;
            EXIT;
          END IF;

          --get sequence
          SELECT AHL_SNAPSHOTS_S.NEXTVAL INTO l_snapshot_id FROM DUAL;

          -- take snapshot now
          AHL_SNAPSHOTS_PKG.INSERT_ROW
          (
            X_SNAPSHOT_ID           => l_snapshot_id,
            X_OBJECT_VERSION_NUMBER => 1,
            X_SNAPSHOT_NUMBER       => l_snapshot_number,
            X_LAST_UPDATE_DATE      => SYSDATE,
            X_LAST_UPDATED_BY       => fnd_global.user_id,
            X_CREATION_DATE         => SYSDATE,
            X_CREATED_BY            => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN     => fnd_global.login_id,
            X_VISIT_ID              => p_x_cost_price_rec.visit_id,
            X_VISIT_TASK_ID         => summary_tasks_rec.visit_task_id,
            X_MR_ID                 => summary_tasks_rec.mr_id,
            X_ESTIMATED_PRICE       => null,
            X_ACTUAL_PRICE          => null,
            X_ESTIMATED_COST        => l_estimated_cost,
            X_ACTUAL_COST           => l_actual_cost,
            X_ATTRIBUTE_CATEGORY    => null,
            X_ATTRIBUTE1            => null,
            X_ATTRIBUTE2            => null,
            X_ATTRIBUTE3            => null,
            X_ATTRIBUTE4            => null,
            X_ATTRIBUTE5            => null,
            X_ATTRIBUTE6            => null,
            X_ATTRIBUTE7            => null,
            X_ATTRIBUTE8            => null,
            X_ATTRIBUTE9            => null,
            X_ATTRIBUTE10           => null,
            X_ATTRIBUTE11           => null,
            X_ATTRIBUTE12           => null,
            X_ATTRIBUTE13           => null,
            X_ATTRIBUTE14           => null,
            X_ATTRIBUTE15           => null
          );
        END IF;
        CLOSE workorder_csr;
     END LOOP;

     -- take a snapshot of all other tasks
     FOR other_tasks_rec IN other_tasks_snapshot_csr(p_x_cost_price_rec.visit_id) LOOP
        AHL_VWP_COST_PVT.Calculate_Task_Cost
        (
            p_visit_task_id    => other_tasks_rec.visit_task_id,
            p_session_id     => p_x_cost_price_rec.mr_session_id,
            x_Actual_cost    => l_actual_cost,
            x_Estimated_cost   => l_estimated_cost,
            x_return_status    => x_return_status
        );

        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_CALC_TCOST_ERR');
           FND_MSG_PUB.ADD;
           IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
              fnd_log.level_error,
              'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot',
              'AHL_VWP_COST_PVT.Calculate_Task_Cost API threw error :other: x_return_status : ' || x_return_status
            );
           END IF;
           EXIT;
        END IF;

        --get sequence
        SELECT AHL_SNAPSHOTS_S.NEXTVAL INTO l_snapshot_id FROM DUAL;

        -- take snapshot now
        AHL_SNAPSHOTS_PKG.INSERT_ROW
        (
            X_SNAPSHOT_ID           => l_snapshot_id,
            X_OBJECT_VERSION_NUMBER => 1,
            X_SNAPSHOT_NUMBER       => l_snapshot_number,
            X_LAST_UPDATE_DATE      => SYSDATE,
            X_LAST_UPDATED_BY       => fnd_global.user_id,
            X_CREATION_DATE         => SYSDATE,
            X_CREATED_BY            => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN     => fnd_global.login_id,
            X_VISIT_ID              => p_x_cost_price_rec.visit_id,
            X_VISIT_TASK_ID         => other_tasks_rec.visit_task_id,
            X_MR_ID                 => other_tasks_rec.mr_id,
            X_ESTIMATED_PRICE       => null,
            X_ACTUAL_PRICE          => null,
            X_ESTIMATED_COST        => l_estimated_cost,
            X_ACTUAL_COST           => l_actual_cost,
            X_ATTRIBUTE_CATEGORY    => null,
            X_ATTRIBUTE1            => null,
            X_ATTRIBUTE2            => null,
            X_ATTRIBUTE3            => null,
            X_ATTRIBUTE4            => null,
            X_ATTRIBUTE5            => null,
            X_ATTRIBUTE6            => null,
            X_ATTRIBUTE7            => null,
            X_ATTRIBUTE8            => null,
            X_ATTRIBUTE9            => null,
            X_ATTRIBUTE10           => null,
            X_ATTRIBUTE11           => null,
            X_ATTRIBUTE12           => null,
            X_ATTRIBUTE13           => null,
            X_ATTRIBUTE14           => null,
            X_ATTRIBUTE15           => null
        );
     END LOOP;

     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
      'ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.create_cost_snapshot.end',
      'At the end of PLSQL procedure'
    );
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO create_cost_snapshot;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO create_cost_snapshot;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO create_cost_snapshot;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'create_cost_snapshot',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END create_cost_snapshot;

--------------------------------------------------------------------------
-- Procedure to find out all visit items which have no price list       --
--------------------------------------------------------------------------
PROCEDURE get_visit_items_no_price
    (
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2,
    p_cost_price_rec        IN             AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_cost_price_tbl        OUT NOCOPY     Cost_Price_Tbl_Type
    )
AS
l_api_name               VARCHAR2(30) :='GET_VISIT_ITEMS_NO_PRICE';
l_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);
l_flag               VARCHAR2(1);
l_commit                 VARCHAR2(1)  := FND_API.G_FALSE;
l_release_visit_required VARCHAR2(1)  :='N';
l_module_name            VARCHAR2(200):='ahl.plsql.AHL_VWP_VISIT_CST_PR_PVT.get_visit_items_no_price';

l_cost_price_rec        AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type:=p_cost_price_rec;
l_job_status_code       AHL_WORKORDERS_V.JOB_STATUS_CODE%TYPE;
l_job_status_meaning    AHL_WORKORDERS_V.JOB_STATUS_MEANING%TYPE;

l_cost_price_tbl1       Cost_Price_Tbl_Type;
l_cost_price_tbl        Cost_Price_Tbl_Type;

l_api_version            NUMBER       := 1.0;
l_index                  NUMBER       := 0;
l_msg_count              NUMBER;
--
Cursor  c_visit_csr(c_visit_id in number)
Is
Select  visit_id,
        outside_party_flag,
        organization_id,
        price_list_id,
        service_request_id
From  ahl_visits_b
where visit_id=c_visit_id;

l_visit_rec     c_visit_csr%rowtype;

Cursor c_customer_csr(c_incident_id  in number)
Is
Select customer_id
From  CS_INCIDENTS_ALL_B
Where incident_id=c_incident_id;


-- Get all the root mr
Cursor c_summary_tasks_csr(c_visit_id in number)
is
Select visit_id,
       visit_task_id,
       originating_task_id
from ahl_visit_tasks_vl
where originating_task_id is null
and visit_id =c_visit_id
and task_type_code ='SUMMARY'
AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')
and mr_id is not null;

l_summary_recs          c_summary_tasks_csr%rowtype;

-- Get all the unassociated tasks
Cursor c_task_csr(c_visit_id in number)
Is
Select visit_task_id,
       visit_id,
       mr_id
From ahl_visit_tasks_vl
where visit_id=c_visit_id
AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')
and task_type_code='UNASSOCIATED';

l_task_csr_rec          c_task_csr%rowtype;

--Get min(start_time), max(end_time) for summary tasks
CURSOR get_summary_task_times_csr(p_task_id IN NUMBER)IS
      SELECT min(start_date_time), max(end_date_time)
      FROM ahl_visit_tasks_vl VST
      START WITH visit_task_id  = p_task_id
      AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
      CONNECT BY originating_task_id = PRIOR visit_task_id;
--
BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_procedure,
                        l_module_name,
                        'Start of '||l_api_name
    );
        END IF;

        SAVEPOINT Get_Visit_Items_no_price_PVT;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF FND_API.to_boolean(p_init_msg_list)
        THEN
                 FND_MSG_PUB.initialize;
        END IF;

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
            l_module_name,
            'Request to get items without price for Visit ID : ' || l_cost_price_rec.visit_id
    );
        END IF;


      -- Check for Required Parameters
     IF(l_cost_price_rec.visit_id IS NULL OR
      l_cost_price_rec.visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
          'Visit id is mandatory but found null in input '
        );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;



    -- Get visit info
        Open  c_visit_csr(l_cost_price_rec.visit_id);
        Fetch c_visit_csr into l_visit_rec;
        If c_visit_csr%notfound
        Then
                Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_INVALID');
                Fnd_Msg_Pub.ADD;
                Close c_visit_csr;
                RAISE FND_API.G_EXC_ERROR;
        End if;
        Close c_visit_csr;

    -- Release visit if required
        AHL_VWP_VISIT_CST_PR_PVT.check_for_release_visit
                (
                    p_visit_id                    =>l_visit_rec.visit_id,
                    x_release_visit_required      =>l_release_visit_required
                );


    IF l_release_visit_required ='Y' THEN

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'Before calling ahl vwp proj prod pvt.release visit'
      );
    END IF;

     AHL_VWP_PROJ_PROD_PVT.release_visit
            (
            p_api_version       =>l_api_version,
            p_init_msg_list     =>Fnd_Api.g_false,
            p_commit            =>Fnd_Api.g_false,
            p_validation_level  =>Fnd_Api.g_valid_level_full,
            p_module_type       => 'CST',
            x_return_status     =>l_return_Status,
            x_msg_count         =>x_msg_count,
            x_msg_data          =>x_msg_data,
                p_visit_id          =>l_visit_rec.visit_id
            );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
             'After calling ahl vwp proj prod pvt.Release Visit task wo Return Status : '|| l_return_status
        );
    END IF;

       -- Check Error Message stack.
       IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
       END IF;

   END IF; -- release required flag

-- Check outside party flag

                If l_visit_rec.outside_party_flag ='N'
                then
                        FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_OUTSDPRTY_FLAG');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                 --Display an error message `Visit number visit_number is not an outside party.'
                END if;

-- Populate pricing attributes

-- Populate price list ID

         if l_visit_rec.price_list_id is not Null and l_visit_rec.price_list_id <> FND_API.G_MISS_NUM
         then
                  l_cost_price_rec.price_list_id :=l_visit_rec.price_list_id;
         Else
                  FND_MESSAGE.Set_Name('AHL','AHL_VWP_CST_PRICELISTIDNULL'); --AHL_VWP_PRICE_LIST_ID_NULL
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;

         END IF;


         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
          'Price List ID :' ||l_cost_price_rec.price_list_id
        );
         END IF;

        l_cost_price_rec.organization_id:=l_visit_rec.organization_id;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
          'Organization ID :' ||l_cost_price_rec.organization_id
        );
          END IF;


-- Populate customer ID

        Open  c_customer_csr(l_visit_rec.service_request_id);
        fetch c_customer_csr into l_cost_price_rec.customer_id;
        close c_customer_csr;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
          'Customer ID :' ||l_cost_price_rec.customer_id
        );
          END IF;


-- Populate currency code

      AHL_VWP_RULES_PVT.check_currency_for_costing
        (p_visit_id             =>l_visit_rec.visit_id,
         x_currency_code        =>l_cost_price_rec.currency
        );

  -- Error handling
  IF l_cost_price_rec.currency IS NULL THEN
    FND_MESSAGE.Set_Name(G_PKG_NAME,'AHL_VWP_CST_NO_CURRENCY');
    FND_MSG_PUB.ADD;
   IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
     (
         fnd_log.level_error,
          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME,
         'No curency is defined for the organization of the visit'
      );
   END IF;
   RAISE FND_API.G_EXC_ERROR;
  END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
          'Currency Code :' ||l_cost_price_rec.currency
        );
          END IF;


        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_statement,
                        l_module_name,
                        'Before Call to AHL_VWP_RULES_PVT.Check_Job_Status'
    );
        END IF;


                AHL_VWP_RULES_PVT.Check_Job_Status
                (
                    p_id                => l_cost_price_rec.visit_id,
                    p_is_task_flag      => 'N',
                    x_status_code       => l_job_status_code,
                    x_status_meaning    => l_job_status_meaning
                );

  IF (l_job_status_code is NULL) THEN
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
          fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
          'Job Status :' ||l_job_status_code
        );
          END IF;


      --- Get all the Root MRs in the visit
      OPEN  c_summary_tasks_csr(l_cost_price_rec.visit_id);
      LOOP
            FETCH c_summary_tasks_csr into l_summary_recs;
            EXIT  WHEN c_summary_tasks_csr%notfound;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'Current Task ID:  ' || l_summary_recs.visit_task_id
                              );
            END IF;

                l_cost_price_rec.visit_task_id:=l_summary_recs.visit_task_id;
                OPEN get_summary_task_times_csr(l_cost_price_rec.visit_task_id);
                FETCH get_summary_task_times_csr INTO l_cost_price_rec.Task_Start_Date,
                                                    l_cost_price_rec.Task_END_Date;
                CLOSE get_summary_task_times_csr;

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                   fnd_log.string
                   (
                       fnd_log.level_statement,
                       'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                       'task_start_date : ' ||l_cost_price_rec.task_start_date
                   );
             END IF;

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                  (
                       fnd_log.level_statement,
                       l_module_name,
                       'Before Call to AHL_VWP_MR_CST_PR_PVT.get_mr_items_no_price'
                  );
             END IF;


                   AHL_VWP_MR_CST_PR_PVT.get_mr_items_no_price
                         (
                          p_api_version          =>l_api_version,
                            p_init_msg_list        =>Fnd_Api.g_false,
                          p_commit               =>Fnd_Api.g_false,
                          p_validation_level     =>Fnd_Api.g_valid_level_full,
                                p_module_type          =>'VST',
                          x_return_status        =>l_return_Status,
                          x_msg_count            =>x_msg_count,
                          x_msg_data             =>x_msg_data,
                                p_cost_price_rec       =>l_cost_price_rec,
                                x_cost_price_tbl       =>l_cost_price_tbl1
                                );


                                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                                fnd_log.string
                                (
                                fnd_log.level_statement,
                                l_module_name,
                                'After Call to AHL_VWP_MR_CST_PR_PVT.get_mr_items_no_price'
                                );
                                END IF;

 -- Merge the return value of the child to the current total
        IF  l_cost_price_tbl.count =0 THEN

           l_cost_price_tbl :=l_cost_price_tbl1;

        ELSIF l_cost_price_tbl1.count > 0
           THEN

                l_index:=l_cost_price_tbl.count;

                FOR i in l_cost_price_tbl1.first .. l_cost_price_tbl1.last
                LOOP
                        l_cost_price_tbl(l_index):=l_cost_price_tbl1(i);
                        l_index:=l_index+1;
                END LOOP;
        END IF;
       END LOOP;
       CLOSE c_summary_tasks_csr;

  -- Get all the unassociated tasks

       OPEN  c_task_csr(l_cost_price_rec.visit_id);
       LOOP
           FETCH c_task_csr into l_task_csr_rec;
           EXIT WHEN c_task_csr%NOTFOUND;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(
               fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
               'Current Task ID:  ' || l_task_csr_rec.visit_task_id
               );
           END IF;

            l_cost_price_rec.visit_task_id:=l_task_csr_rec.visit_task_id;
            --Fetch the min(start_time), max(end_time) for summary task
            OPEN get_summary_task_times_csr(l_cost_price_rec.visit_task_id);
            FETCH get_summary_task_times_csr INTO l_cost_price_rec.Task_Start_Date,
                                                    l_cost_price_rec.Task_END_Date;
            CLOSE get_summary_task_times_csr;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                     fnd_log.string
                       (
                        fnd_log.level_statement,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                        'task_start_date : ' ||l_cost_price_rec.task_start_date
                        );
                END IF;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string
                     (
                       fnd_log.level_statement,
                        l_module_name,
                        'Before Call to AHL_VWP_TASK_CST_PR_PVt.get_task_items_no_price'
                    );
                END IF;

                AHL_VWP_TASK_CST_PR_PVT.get_task_items_no_price
                (
                    p_api_version          =>p_api_version,
                    p_init_msg_list        =>fnd_api.g_false,
                    p_commit               =>fnd_api.g_false,
                    p_validation_level     =>p_validation_level,
                    p_module_type          =>'VST',
                    x_return_status        =>l_return_status,
                    x_msg_count            =>x_msg_count,
                    x_msg_data             =>x_msg_data,
                    p_cost_price_rec       =>l_cost_price_rec,
                    x_cost_price_tbl       =>l_cost_price_tbl1
                 );

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                    fnd_log.string
                    (
                        fnd_log.level_statement,
                        l_module_name,
                        'After Call to AHL_VWP_TASK_CST_PR_PVt.get_task_items_no_price'
                    );
                END IF;

            -- Merge the return value of the child to the current total
        IF  l_cost_price_tbl.count = 0 THEN

           l_cost_price_tbl :=l_cost_price_tbl1;

        ELSIF l_cost_price_tbl1.count > 0 THEN

           l_index:=l_cost_price_tbl.count;

           FOR i IN l_cost_price_tbl1.first .. l_cost_price_tbl1.last
           LOOP
                 l_cost_price_tbl(l_index) := l_cost_price_tbl1(i);
                 l_index := l_index + 1;
           END LOOP;

        END IF;

     END LOOP;  -- All unassociated tasks
     CLOSE c_task_csr;

     -- Check Error Message stack.
     IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

        x_cost_price_tbl:=l_cost_price_tbl;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
            (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Total number of items w/o price for the MR:  ' || x_cost_price_tbl.count
            );
     END IF;

     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string
           (
               fnd_log.level_procedure,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'At the end of the procedure');
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Get_Visit_Items_no_price_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Visit_Items_no_price_PVT;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_Visit_Items_no_price_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Get_Visit_Items_no_price;

--------------------------------------------------------------------------------
------- Check various conditions and release visit if needed
---------------------------------------------------------------------------------
PROCEDURE Check_for_Release_Visit
(
  p_visit_id                    IN  NUMBER,
  x_release_visit_required      OUT NOCOPY        VARCHAR2
)
AS
--Bug fix #4542684 10Aug2005 yazhou starts
-- Cursor to retrieve visit info
Cursor c_visit_csr(c_visit_id in number)
Is
Select any_task_chg_flag, status_code
From ahl_visits_b
where visit_id=c_visit_id;
--Bug fix #4542684 10Aug2005 yazhou ends

-- Cursor to get all tasks associated to visit
-- Which should have workorders created in production
CURSOR c_get_visit_tasks_cur (C_VISIT_ID IN NUMBER)
IS
SELECT vt.visit_id,
vt.visit_task_id,
vt.visit_task_number
FROM ahl_visit_tasks_vl vt
WHERE vt.visit_id = C_VISIT_ID
AND not (vt.task_type_code = 'SUMMARY' AND VT.mr_id IS NULL)
AND NVL(vt.status_code, 'Y') <> NVL ('DELETED', 'X');

l_visit_tasks_rec c_get_visit_tasks_cur%ROWTYPE;

-- Cursor to check master workorder has been created for visit
CURSOR c_get_master_wo_cur (C_VISIT_ID IN NUMBER)
IS
SELECT workorder_id,
workorder_name,
wip_entity_id,
visit_id,
master_workorder_flag
FROM ahl_workorders wo
WHERE wo.visit_id = C_VISIT_ID
AND wo.visit_task_id IS NULL
AND wo.status_code NOT IN (22,7)
AND wo.master_workorder_flag = 'Y';

l_master_wo_rec c_get_master_wo_cur%ROWTYPE;

-- Cursor to check child workorders has been created for visit tasks
CURSOR c_check_wo_exists_cur (C_VISIT_TASK_ID IN NUMBER)
IS
SELECT 1
FROM ahl_workorders wo
WHERE wo.visit_task_id = C_VISIT_TASK_ID
AND wo.status_code NOT IN (22,7);

-- Local Variables

   l_api_name               VARCHAR2(30) := 'Check_To_Release_Visit ';
   l_release_visit_required     VARCHAR2(1)  := 'N';
   l_any_task_chg_flag          VARCHAR2(1)  := 'N';
   --Bug fix #4542684 10Aug2005 yazhou starts
   l_visit_status_code          VARCHAR2(30);
   --Bug fix #4542684 10Aug2005 yazhou ends
   l_api_version              NUMBER       := 1.0;
   l_dummy                      NUMBER;

BEGIN

IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
             'At the start of the procedure');
END IF;

--Bug fix #4542684 10Aug2005 yazhou starts
-- Retrieve visit any task changed flag
 OPEN  c_visit_csr(p_visit_id);
 FETCH c_visit_csr into l_any_task_chg_flag, l_visit_status_code;
 CLOSE c_visit_csr;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    '.any_task_chg_flag : ' || l_any_task_chg_flag
    );

  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    '.visit status code : ' || l_visit_status_code
    );

  END IF;

    IF l_visit_status_code ='RELEASED' THEN
       x_release_visit_required  := 'N';
       RETURN;
    END IF;

--Bug fix #4542684 10Aug2005 yazhou ends

-- Check an_task_chg_flag of the visit to decide whether releasing visit is required
  IF l_any_task_chg_flag = 'Y' THEN
       l_release_visit_required  := 'Y';
    END IF;

-- Check for master workorder

    IF l_release_visit_required ='N' THEN

        OPEN c_get_master_wo_cur(p_visit_id);
      FETCH c_get_master_wo_cur INTO l_master_wo_rec;
      CLOSE c_get_master_wo_cur;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Visit Master Workorder Id : ' || l_master_wo_rec.workorder_id
        );
    END IF;

    -- Master workorder not found then call ahl_vwp_proj_prod_pvt.release_visit
    IF l_master_wo_rec.workorder_id IS NULL THEN

              l_release_visit_required := 'Y';

        END IF;
    END IF;

 -- Check if workorder have been created for all the tasks in the visit
    IF l_release_visit_required ='N' THEN

      OPEN c_get_visit_tasks_cur(p_visit_id);
      LOOP
          FETCH c_get_visit_tasks_cur INTO l_visit_tasks_rec;
          EXIT WHEN c_get_visit_tasks_cur%NOTFOUND;

        IF l_visit_tasks_rec.visit_task_id IS NOT NULL THEN
          -- Check workorder exists
           OPEN c_check_wo_exists_cur(l_visit_tasks_rec.visit_task_id);
           FETCH c_check_wo_exists_cur INTO l_dummy;

               IF c_check_wo_exists_cur%NOTFOUND THEN
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
              (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'workorder not exist for visit task '||l_visit_tasks_rec.visit_task_id
              );
                END IF;

                    l_release_visit_required := 'Y';
                CLOSE c_check_wo_exists_cur;

                EXIT;
         END IF;  -- workorder not found

               CLOSE c_check_wo_exists_cur;
       END IF;  -- task_id not null
    END LOOP;

    CLOSE c_get_visit_tasks_cur;
  END IF; -- released visit flag

       x_release_visit_required := l_release_visit_required;
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
        (
           fnd_log.level_statement,
           'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
           'x_release_visit_required:  '||x_release_visit_required
        );
       END IF;

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string
               (
                   fnd_log.level_statement,
                  'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'At the end of the procedure'
               );
       END IF;

END Check_for_Release_Visit;

END AHL_VWP_VISIT_CST_PR_PVT;

/
