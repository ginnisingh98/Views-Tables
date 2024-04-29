--------------------------------------------------------
--  DDL for Package Body FPA_PROCESS_RST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PROCESS_RST_PVT" as
/* $Header: FPAVRSTB.pls 120.1 2005/08/18 11:48:28 appldev ship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_PROCESS_RST_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'PROCESS_RST';

PROCEDURE Update_Calc_Pjt_Scorecard_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_planning_cycle_id     IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_scorecard_tbl         IN              FPA_SCORECARDS_PVT.FPA_SCORECARD_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Calc_Pjt_Sc';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(200)         := null;

BEGIN


      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

      x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Process_Pvt.Update_Calc_Pjt_Scorecard_Aw',
              x_return_status => x_return_status);


        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

      FPA_UTILITIES_PVT.Attach_AW
                        (p_api_version => l_api_version,
                         p_attach_mode => 'rw',
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);


      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

      FPA_SCORECARDS_PVT.Update_Calc_Pjt_Scorecard_Aw
                        (p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         p_commit             => p_commit,
                         p_planning_cycle_id  => p_planning_cycle_id,
                         p_project_id         => p_project_id,
                         p_scorecard_tbl      => p_scorecard_tbl,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data);

     -- Update and commit our changes
     IF (p_commit = FND_API.G_TRUE) THEN
         dbms_aw.execute('UPDATE');
         COMMIT;
     END IF;

     FPA_UTILITIES_PVT.Detach_AW
                        (p_api_version => 1.0,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

            x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when OTHERS then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'OTHERS',
                p_msg_log   => l_msg_log||SQLERRM,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

END Update_Calc_Pjt_Scorecard_Aw;

PROCEDURE Update_Calc_Scen_Scorecard_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_planning_cycle_id     IN              NUMBER,
    p_scenario_id           IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_scorecard_tbl         IN              FPA_SCORECARDS_PVT.FPA_SCORECARD_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Calc_Scen';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(200)         := null;

BEGIN

      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

      x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Process_Pvt.Update_Calc_Scen',
              x_return_status => x_return_status);


        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

      FPA_UTILITIES_PVT.Attach_AW
                        (p_api_version => l_api_version,
                         p_attach_mode => 'rw',
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);


      x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;


      FPA_SCORECARDS_PVT.Update_Calc_Scen_Scorecard_Aw
                        (p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         p_commit             => p_commit,
                         p_planning_cycle_id  => p_planning_cycle_id,
                         p_scenario_id        => p_scenario_id,
                         p_project_id         => p_project_id,
                         p_scorecard_tbl      => p_scorecard_tbl,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data);

     -- Update and commit our changes
     IF (p_commit = FND_API.G_TRUE) THEN
         dbms_aw.execute('UPDATE');
         COMMIT;
     END IF;

     -- Detach AW Workspace
     FPA_UTILITIES_PVT.Detach_AW
                        (p_api_version => 1.0,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);

   x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

           x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

            x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
                p_msg_log   => l_msg_log,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

      when OTHERS then

           FPA_UTILITIES_PVT.Detach_AW(
                             p_api_version => l_api_version,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
                p_api_name  => l_api_name,
                p_pkg_name  => G_PKG_NAME,
                p_exc_name  => 'OTHERS',
                p_msg_log   => l_msg_log||SQLERRM,
                x_msg_count => x_msg_count,
                x_msg_data  => x_msg_data,
                p_api_type  => G_API_TYPE);

END Update_Calc_Scen_Scorecard_Aw;


END FPA_PROCESS_RST_PVT;

/
