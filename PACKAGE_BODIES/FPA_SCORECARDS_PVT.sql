--------------------------------------------------------
--  DDL for Package Body FPA_SCORECARDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_SCORECARDS_PVT" as
 /* $Header: FPAVSCRB.pls 120.3 2006/03/16 13:06:42 appldev noship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_SCORECARDS_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'SCORECARDS';


PROCEDURE insert_tl_rec(
 p_init_msg_list                IN VARCHAR2,
 p_scorecards_tl_rec            IN  FPA_SCORECARDS_TL_REC,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2
 ) IS

 l_api_version                  CONSTANT NUMBER := 1;
 l_api_name                     CONSTANT VARCHAR2(30) := 'insert_tl_rec';
 l_return_status                VARCHAR2(1) := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
 l_scorecards_tl_rec            FPA_SCORECARDS_TL_REC := p_scorecards_tl_rec;
 l_msg_log                      VARCHAR2(2000)        := null;

 CURSOR get_languages IS
   SELECT *
     FROM FND_LANGUAGES
    WHERE INSTALLED_FLAG IN ('I', 'B');

 -----------------------------------------
 -- Set_Attributes for:FPA_SCORECARDS_TL --
 -----------------------------------------
     FUNCTION Set_Attributes (
       p_scorecards_tl_rec    IN         FPA_SCORECARDS_TL_REC,
       x_scorecards_tl_rec    OUT NOCOPY FPA_SCORECARDS_TL_REC
     ) RETURN VARCHAR2 IS
       l_return_status                VARCHAR2(1) := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
     BEGIN
       x_scorecards_tl_rec                   := p_scorecards_tl_rec;

       x_scorecards_tl_rec.LANGUAGE          := USERENV('LANG');
       x_scorecards_tl_rec.SOURCE_LANG       := USERENV('LANG');
       x_scorecards_tl_rec.CREATED_BY        := FND_GLOBAL.USER_ID;
       x_scorecards_tl_rec.CREATION_DATE     := SYSDATE;
       x_scorecards_tl_rec.LAST_UPDATED_BY   := FND_GLOBAL.USER_ID;
       x_scorecards_tl_rec.LAST_UPDATE_DATE  := SYSDATE;
       x_scorecards_tl_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

       RETURN(l_return_status);

     END Set_Attributes;

BEGIN
  FPA_UTILITIES_PVT.START_ACTIVITY(
          p_api_name      => l_api_name,
          p_pkg_name      => G_PKG_NAME,
          p_init_msg_list => p_init_msg_list,
          p_msg_log       => 'Entering Fpa_Scorecards_Pvt.insert_tl_rec');

 --- Setting item attributes
   l_return_status := Set_Attributes(
                      p_scorecards_tl_rec,
                      l_scorecards_tl_rec);

   FOR l_lang_rec IN get_languages LOOP
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'l_lang_rec.language_code '||l_lang_rec.language_code);
       l_scorecards_tl_rec.LANGUAGE := l_lang_rec.language_code;
       INSERT INTO FPA_SCORECARDS_TL(
            project_id,
            strategic_obj_id,
            scenario_id,
            comments,
            language,
            source_lang,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login)
       VALUES (
            l_scorecards_tl_rec.project_id,
            l_scorecards_tl_rec.strategic_obj_id,
            l_scorecards_tl_rec.scenario_id,
            l_scorecards_tl_rec.comments,
            l_scorecards_tl_rec.language,
            l_scorecards_tl_rec.source_lang,
            l_scorecards_tl_rec.created_by,
            l_scorecards_tl_rec.creation_date,
            l_scorecards_tl_rec.last_updated_by,
            l_scorecards_tl_rec.last_update_date,
            l_scorecards_tl_rec.last_update_login);

   END LOOP;

   x_return_status     := l_return_status;

   FPA_UTILITIES_PVT.END_ACTIVITY(
                p_api_name     => l_api_name,
                p_pkg_name     => G_PKG_NAME,
                p_msg_log      => null,
                x_msg_count    => x_msg_count,
                x_msg_data     => x_msg_data);

EXCEPTION

  when OTHERS then
     -- to change for using call with no rollback
     x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => G_PKG_NAME,
        p_exc_name  => 'OTHERS',
        p_msg_log   => l_msg_log||SQLERRM,
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => G_API_TYPE);

END insert_tl_rec;



PROCEDURE update_tl_rec(
 p_init_msg_list                IN VARCHAR2,
 p_scorecards_tl_rec            IN  FPA_SCORECARDS_TL_REC,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 x_return_status                OUT NOCOPY VARCHAR2
) IS

 l_api_version                  CONSTANT NUMBER := 1;
 l_api_name                     CONSTANT VARCHAR2(30) := 'update_tl_rec';
 l_return_status                VARCHAR2(1) := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
 l_scorecards_tl_rec            FPA_SCORECARDS_TL_REC := p_scorecards_tl_rec;
 l_msg_log                      VARCHAR2(2000)        := null;
 -----------------------------------------
 -- Set_Attributes for:FPA_SCORECARDS_TL --
 -----------------------------------------
     FUNCTION Set_Attributes (
       p_scorecards_tl_rec    IN         FPA_SCORECARDS_TL_REC,
       x_scorecards_tl_rec    OUT NOCOPY FPA_SCORECARDS_TL_REC
     ) RETURN VARCHAR2 IS
       l_return_status                VARCHAR2(1) := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
     BEGIN
       x_scorecards_tl_rec                   := p_scorecards_tl_rec;

       x_scorecards_tl_rec.LAST_UPDATED_BY   := FND_GLOBAL.USER_ID;
       x_scorecards_tl_rec.LAST_UPDATE_DATE  := SYSDATE;
       x_scorecards_tl_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

       RETURN(l_return_status);

     END Set_Attributes;

BEGIN
  FPA_UTILITIES_PVT.START_ACTIVITY(
          p_api_name      => l_api_name,
          p_pkg_name      => G_PKG_NAME,
          p_init_msg_list => p_init_msg_list,
          p_msg_log       => 'Entering Fpa_Scorecards_Pvt.update_tl_rec');

 --- Setting item attributes
   l_return_status := Set_Attributes(
                      p_scorecards_tl_rec,
                      l_scorecards_tl_rec);

   UPDATE fpa_scorecards_tl
       SET   comments              = l_scorecards_tl_rec.comments,
             last_updated_by       = l_scorecards_tl_rec.last_updated_by,
             last_update_date      = l_scorecards_tl_rec.last_update_date,
             last_update_login     = l_scorecards_tl_rec.last_update_login
       WHERE project_id            = l_scorecards_tl_rec.project_id AND
             scenario_id           = l_scorecards_tl_rec.scenario_id AND
             strategic_obj_id      = l_scorecards_tl_rec.strategic_obj_id AND
             language              = userenv('LANG') AND
             source_lang           = userenv('LANG');

   x_return_status     := l_return_status;

   FPA_UTILITIES_PVT.END_ACTIVITY(
                p_api_name     => l_api_name,
                p_pkg_name     => G_PKG_NAME,
                p_msg_log      => null,
                x_msg_count    => x_msg_count,
                x_msg_data     => x_msg_data);

EXCEPTION

  when OTHERS then
     -- to change for using call with no rollback
     x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => G_PKG_NAME,
        p_exc_name  => 'OTHERS',
        p_msg_log   => l_msg_log||SQLERRM,
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => G_API_TYPE);

END update_tl_rec;



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

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Calc_Pjt_Score';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

 i NUMBER := 0;
 l_scorecard_rec           FPA_SCORECARDS_PVT.FPA_SCORECARD_REC_TYPE;
 l_tl_exists              VARCHAR2(1) := null;
 l_scorecards_tl_rec       FPA_SCORECARDS_TL_REC;

 cursor check_comments_csr (p_project_id        IN NUMBER,
                            p_strategic_obj_id  IN NUMBER) IS
   select 'T'
        from fpa_scorecards_tl
   where project_id           = p_project_id
        and strategic_obj_id  = p_strategic_obj_id
        and scenario_id = -1
        and language = USERENV('LANG')
        and source_lang = USERENV('LANG');


 BEGIN

--      l_return_status      := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

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
              p_msg_log       => 'Entering Fpa_Scorecards_Pvt.Update_Calc_Pjt_Scorecard_Aw',
              x_return_status => x_return_status);

        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

    if(p_scorecard_tbl.count > 0) then

        dbms_aw.execute('LMT project_d TO ' || p_project_id );

        l_scorecards_tl_rec.project_id    := p_project_id;
        l_scorecards_tl_rec.scenario_id   := -1;


        for i in p_scorecard_tbl.FIRST..p_scorecard_tbl.LAST
        loop

            l_scorecard_rec := p_scorecard_tbl(i);

            l_tl_exists := null;
            open check_comments_csr(p_project_id,
                                    l_scorecard_rec.strategic_obj_id);
            fetch check_comments_csr into l_tl_exists;
            close check_comments_csr;

            l_scorecards_tl_rec.strategic_obj_id := l_scorecard_rec.strategic_obj_id;
            l_scorecards_tl_rec.comments      := l_scorecard_rec.comments;

            if (l_tl_exists is not null and l_tl_exists = FND_API.G_TRUE) then

               update_tl_rec(
                    p_init_msg_list     => p_init_msg_list,
                    p_scorecards_tl_rec => l_scorecards_tl_rec,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    x_return_status     => l_return_status
                    );

            else

                insert_tl_rec(
                    p_init_msg_list     => p_init_msg_list,
                    p_scorecards_tl_rec => l_scorecards_tl_rec,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    x_return_status     => l_return_status
                    );

            end if;

         --DIMENSION investment_criteria from strategic_obj_d
         dbms_aw.execute('LMT strategic_obj_d      TO    ' || l_scorecard_rec.strategic_obj_id );

         if(l_scorecard_rec.new_score is null) then
            dbms_aw.execute('project_entered_obj_score_m = NA' );
         else
            dbms_aw.execute('project_entered_obj_score_m = ' || l_scorecard_rec.new_score );
         end if;

        end loop;

        dbms_aw.execute('CALL CALC_PROJ_SCORECARD_PRG(' ||
                          p_planning_cycle_id || ',' ||
                          p_project_id        || ')' );
        -- Overwrite Root and Financial Category weighted score
        dbms_aw.execute('LMT strategic_obj_d TO strategic_obj_d le 2');
        dbms_aw.execute('project_strategic_obj_weights_score_m = NA' );

    end if;
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;


    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
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

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Calc_Scen_Score';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

 i NUMBER := 0;
 l_scorecard_rec           FPA_SCORECARDS_PVT.FPA_SCORECARD_REC_TYPE;
 l_scorecards_tl_rec       FPA_SCORECARDS_TL_REC;
 l_tl_exists              VARCHAR2(1) := null;

 cursor check_comments_csr (p_project_id        IN NUMBER,
                            p_scenario_id       IN NUMBER,
                            p_strategic_obj_id  IN NUMBER) IS
   select 'T'
        from fpa_scorecards_tl
   where project_id           = p_project_id
        and strategic_obj_id  = p_strategic_obj_id
        and scenario_id       = p_scenario_id
        and language = USERENV('LANG')
        and source_lang = USERENV('LANG');

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
              p_msg_log       => 'Entering Fpa_Scorecards_Pvt.Update_Calc_Scen_Scorecard_Aw',
              x_return_status => x_return_status);

        -- check if activity started successfully
      if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
           l_msg_log := 'start_activity';
           raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
      end if;

    if(p_scorecard_tbl.count > 0) then

        dbms_aw.execute('LMT project_d  TO ' || p_project_id );
        dbms_aw.execute('LMT scenario_d TO ' || p_scenario_id );

        l_scorecards_tl_rec.project_id    := p_project_id;
        l_scorecards_tl_rec.scenario_id   := p_scenario_id;

        for i in p_scorecard_tbl.FIRST..p_scorecard_tbl.LAST
        loop

            l_scorecard_rec := p_scorecard_tbl(i);

            l_tl_exists := null;
            open check_comments_csr(p_project_id,
                                    p_scenario_id,
                                    l_scorecard_rec.strategic_obj_id);

            fetch check_comments_csr into l_tl_exists;
            close check_comments_csr;

            l_scorecards_tl_rec.strategic_obj_id := l_scorecard_rec.strategic_obj_id;
            l_scorecards_tl_rec.comments      := l_scorecard_rec.comments;

            if (l_tl_exists is not null and l_tl_exists = FND_API.G_TRUE) then

              update_tl_rec(
                    p_init_msg_list     => p_init_msg_list,
                    p_scorecards_tl_rec => l_scorecards_tl_rec,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    x_return_status     => l_return_status
                    );
            else

              insert_tl_rec(
                    p_init_msg_list     => p_init_msg_list,
                    p_scorecards_tl_rec => l_scorecards_tl_rec,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    x_return_status     => l_return_status
                    );

            end if;

         --DIMENSION investment_criteria from strategic_obj_d
         dbms_aw.execute('LMT strategic_obj_d      TO    ' || l_scorecard_rec.strategic_obj_id );

         if(l_scorecard_rec.new_score is null) then
            dbms_aw.execute('scenario_project_obj_score_m = NA' );
         else
            dbms_aw.execute('scenario_project_obj_score_m = ' || round(l_scorecard_rec.new_score,1) );
         end if;

        end loop;



         dbms_aw.execute('CALL CALC_SCEN_SCORECARD_PRG(' ||
                           p_planning_cycle_id || ',' ||
                           p_scenario_id || ',' ||
                           p_project_id        || ')' );
        -- Overwrite Root and Financial Category weighted score
        dbms_aw.execute('LMT strategic_obj_d TO strategic_obj_d le 2');
        dbms_aw.execute('scenario_project_obj_wscore_m = NA' );

       dbms_aw.execute('CALL CALC_SCE_COST_WSCORES_PRG(' ||
                           p_scenario_id || ')' );


       dbms_aw.execute('CALL CALC_SCE_CLASS_COST_WSCORES_PRG(' ||
                           p_scenario_id || ',' ||
                           'na,' ||
                           p_project_id  || ')' );

    end if;
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Update_Calc_Scen_Scorecard_Aw;


PROCEDURE Calc_Scenario_Wscores_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_scenario_id           IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Calc_Scenario_Wscores_Aw';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
  l_init_scenario_id       NUMBER := null;
  l_planning_cycle_id      NUMBER := null;

  CURSOR INIT_SCENARIO_CSR (P_SCENARIO_ID IN NUMBER) IS
    SELECT
        PC.PLANNING_CYCLE, SCEI.SCENARIO
    FROM
        FPA_AW_SCE_INFO_V SCEI, FPA_AW_SCE_INFO_V SCE, FPA_AW_SCES_V PC
    WHERE
        SCEI.IS_INITIAL_SCENARIO = 1
    AND SCE.PLANNING_CYCLE = PC.PLANNING_CYCLE
    AND SCEI.PLANNING_CYCLE = PC.PLANNING_CYCLE
    AND PC.SCENARIO = SCE.SCENARIO
    AND SCE.SCENARIO = P_SCENARIO_ID;

  PROCEDURE Calc_Scenario_Wscores(
            p_planning_cycle_id IN NUMBER,
            p_scenario_id       IN NUMBER) IS
    BEGIN

       dbms_aw.execute('CALL CALC_SCEN_SCORECARD_PRG(' ||
                       l_planning_cycle_id || ',' ||
                       p_scenario_id || ',NA)' );

       dbms_aw.execute('CALL CALC_SCE_COST_WSCORES_PRG(' ||
                       p_scenario_id || ')' );

       dbms_aw.execute('CALL CALC_SCE_CLASS_COST_WSCORES_PRG(' ||
                       p_scenario_id || ', NA, NA)' );

    END Calc_Scenario_Wscores;

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Project_Load_Pvt.Calc_Scenario_Wscores_Aw',
              x_return_status => x_return_status);

        -- check if activity started successfully
    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    -- calculate scenario weighted scores
    -- fetch planning cycle (and initial scenario on the planning cycle)
    -- for this scenario

    open  init_scenario_csr(p_scenario_id);
    fetch init_scenario_csr into l_planning_cycle_id, l_init_scenario_id;
    close init_scenario_csr;

    calc_scenario_wscores(l_planning_cycle_id, p_scenario_id);

    -- if p_scenario_id is not intial scenario then calculate new scenario scores
    -- for initial scenario as projects got added to initial scenario also
    -- during this load

    if (l_init_scenario_id is not null and l_init_scenario_id <> p_scenario_id) then
        calc_scenario_wscores(l_planning_cycle_id, l_init_scenario_id);
    end if;


    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Calc_Scenario_Wscores_Aw;

-- The procedure Update_Scenario_App_Scores copies the scores from the approved
-- scenario (scenario id is passed) to the approved scores variable.
PROCEDURE Update_Scenario_App_Scores
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_scenario_id           IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) is

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Scenario_App_Scores';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;

begin

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Project_Load_Pvt.Calc_Scenario_Wscores_Aw',
              x_return_status => x_return_status);

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'FPA_Scorecard_Pvt.Update_Scenario_App_Scores.begin',
          'Setting appropriate dimension limits.'
        );
      END IF;

      dbms_aw.execute('limit scenario_d to ' || p_scenario_id);
      dbms_aw.execute('limit project_d to scenario_project_m');
      dbms_aw.execute('limit planning_cycle_d to scenario_d');
      dbms_aw.execute('limit strategic_obj_d to pc_obj_m');

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'FPA_Scorecard_Pvt.Update_Scenario_App_Scores.',
          'Updating Approved Scores.'
        );
      END IF;

      dbms_aw.execute('project_approved_obj_score_m = scenario_project_obj_score_m');

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'FPA_Scorecard_Pvt.Update_Scenario_App_Scores.end',
          'Finished updating approved projects.'
        );
      END IF;



    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);



end Update_Scenario_App_Scores;



PROCEDURE Handle_Comments
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_scenario_id           IN              NUMBER,
    p_type                  IN              VARCHAR2,
    p_source_scenario_id    IN              NUMBER,
    p_delete_project_id     IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Load_Comments';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
  l_projects               VARCHAR2(2000) := null;
  l_init_scenario_id       NUMBER;
  l_source_scenario_id     NUMBER;

  l_scorecards_tl_rec      FPA_SCORECARDS_PVT.FPA_SCORECARDS_TL_REC;

  CURSOR initial_scenario_csr (p_scenario_id in number) IS
    select
        scei.scenario
    from
        fpa_aw_sce_info_v scei, fpa_aw_sce_info_v sce, fpa_aw_sces_v pc
    where
        scei.is_initial_scenario = 1
    and sce.planning_cycle = pc.planning_cycle
    and scei.planning_cycle = pc.planning_cycle
    and pc.scenario = sce.scenario
    and sce.scenario = p_scenario_id;

  CURSOR pjt_comments_csr (p_scenario_id in number) IS
    select
        sce.scenario scenario,
        sce.project project,
        sce.investment_criteria investment_criteria,
        pjtc.comments comments
    from
        fpa_aw_proj_str_scores_v sce, fpa_scorecards_tl pjtc
    where
        sce.project = pjtc.project_id
        and sce.investment_criteria = pjtc.strategic_obj_id
        and pjtc.scenario_id = -1
        and sce.scenario = p_scenario_id
        and pjtc.language = userenv('LANG')
        and not exists
        (select 1
        from fpa_scorecards_tl sctl
        where sctl.scenario_id = sce.scenario
        and sctl.project_id = sce.project
        and sctl.language = userenv('LANG')
        and sctl.strategic_obj_id = sce.investment_criteria);


  CURSOR pjp_comments_csr (p_source_scenario_id in number,
                           p_scenario_id in number) IS
    select
        pjts.project_id project,
        pjts.strategic_obj_id investment_criteria,
        pjts.comments comments
    from
        fpa_scorecards_tl pjts
    where
        pjts.scenario_id = p_source_scenario_id
        and pjts.language = userenv('LANG')
        and not exists
        (select 1
        from fpa_scorecards_tl sctl
        where sctl.project_id = pjts.project_id
        and sctl.strategic_obj_id = pjts.strategic_obj_id
        and sctl.language = userenv('LANG')
        and sctl.scenario_id = p_scenario_id);


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
              p_msg_log       => 'Entering Fpa_Scorecards_Pvt.Handle_Comments '||p_scenario_id,
              x_return_status => x_return_status);

        -- check if activity started successfully
    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

IF (p_delete_project_id is not null) then
    DELETE
    FROM  FPA_SCORECARDS_TL
    WHERE SCENARIO_ID = P_SCENARIO_ID
    AND   PROJECT_ID  = P_DELETE_PROJECT_ID
    AND   LANGUAGE    = userenv('LANG')
    AND   SOURCE_LANG = userenv('LANG');

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);
    RETURN;
END IF;

OPEN  initial_scenario_csr(p_scenario_id);
FETCH initial_scenario_csr INTO l_init_scenario_id;
CLOSE initial_scenario_csr;


IF (p_type = 'PJT') THEN

    FOR pjt_comments_csr_rec IN pjt_comments_csr(p_scenario_id) LOOP

         l_scorecards_tl_rec.scenario_id        := pjt_comments_csr_rec.scenario;
         l_scorecards_tl_rec.project_id         := pjt_comments_csr_rec.project;
         l_scorecards_tl_rec.strategic_obj_id   := pjt_comments_csr_rec.investment_criteria;
         l_scorecards_tl_rec.comments           := pjt_comments_csr_rec.comments;

         insert_tl_rec(
               p_init_msg_list     => p_init_msg_list,
               p_scorecards_tl_rec => l_scorecards_tl_rec,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               x_return_status     => l_return_status);
    END LOOP;

    IF pjt_comments_csr%ISOPEN THEN
        CLOSE pjt_comments_csr;
    END IF;

   IF(l_init_scenario_id <> p_scenario_id) THEN
        FOR pjt_comments_csr_rec IN pjt_comments_csr(l_init_scenario_id) LOOP

             l_scorecards_tl_rec.scenario_id        := pjt_comments_csr_rec.scenario;
             l_scorecards_tl_rec.project_id         := pjt_comments_csr_rec.project;
             l_scorecards_tl_rec.strategic_obj_id   := pjt_comments_csr_rec.investment_criteria;
             l_scorecards_tl_rec.comments           := pjt_comments_csr_rec.comments;

             insert_tl_rec(
                   p_init_msg_list     => p_init_msg_list,
                   p_scorecards_tl_rec => l_scorecards_tl_rec,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   x_return_status     => l_return_status);
        END LOOP;

        IF pjt_comments_csr%ISOPEN THEN
            CLOSE pjt_comments_csr;
        END IF;
    END IF;

  ELSIF (p_type = 'PJP') then

    if (p_source_scenario_id is null) then
        l_source_scenario_id := l_init_scenario_id;
    else
        l_source_scenario_id := p_source_scenario_id;
    end if;

    FOR pjp_comments_csr_rec IN pjp_comments_csr(l_source_scenario_id, p_scenario_id) LOOP

         l_scorecards_tl_rec.scenario_id        := p_scenario_id;
         l_scorecards_tl_rec.project_id         := pjp_comments_csr_rec.project;
         l_scorecards_tl_rec.strategic_obj_id   := pjp_comments_csr_rec.investment_criteria;
         l_scorecards_tl_rec.comments           := pjp_comments_csr_rec.comments;

         insert_tl_rec(
            p_init_msg_list     => p_init_msg_list,
            p_scorecards_tl_rec => l_scorecards_tl_rec,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            x_return_status     => l_return_status);

    END LOOP;

    IF pjp_comments_csr%ISOPEN THEN
        CLOSE pjp_comments_csr;
    END IF;

  END IF; -- elsif PJP

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Handle_Comments;



FUNCTION Read_Only(
   p_planning_cycle_id    IN  NUMBER,
   p_scenario_id          IN  NUMBER) RETURN VARCHAR2 IS

  CURSOR PC_SCENARIO_CSR (P_SCENARIO_ID IN NUMBER) IS
    SELECT
        PC.PC_STATUS, PC.PORTFOLIO, PC.PLANNING_CYCLE,
        SCE.RECOMMENDED_FLAG, SCE.APPROVED_FLAG, SCE.IS_INITIAL_SCENARIO
    FROM
        FPA_AW_PC_INFO_V PC, FPA_AW_SCES_V SCEP, FPA_AW_SCE_INFO_V SCE
    WHERE
        SCEP.SCENARIO = SCE.SCENARIO
    AND SCEP.PLANNING_CYCLE = PC.PLANNING_CYCLE
    AND SCEP.SCENARIO = P_SCENARIO_ID;

  CURSOR PC_CSR (P_PC_ID IN NUMBER) IS
    SELECT
        PC.PC_STATUS, PC.PORTFOLIO, PC.SCENARIO_COUNT
    FROM
        FPA_AW_PC_INFO_V PC
    WHERE
        PC.PLANNING_CYCLE = P_PC_ID;

  l_priv_develop_scen VARCHAR2(1) := null;
  l_portfolio_id    NUMBER;
  l_pc_id           NUMBER;
  l_scen_count      NUMBER;
  l_pc_status       FPA_AW_PC_INFO_V.PC_STATUS%TYPE;
  l_scen_rec_flag   FPA_AW_SCE_INFO_V.RECOMMENDED_FLAG%TYPE;
  l_scen_app_flag   FPA_AW_SCE_INFO_V.APPROVED_FLAG%TYPE;
  l_scen_ini_flag   FPA_AW_SCE_INFO_V.IS_INITIAL_SCENARIO%TYPE;

BEGIN

    l_pc_id := p_planning_cycle_id;

    if(p_scenario_id is not null) then
        open  pc_scenario_csr (p_scenario_id);
        fetch pc_scenario_csr into l_pc_status, l_portfolio_id, l_pc_id,
                                   l_scen_rec_flag, l_scen_app_flag,
                                   l_scen_ini_flag;
        close pc_scenario_csr;
        if(l_scen_rec_flag = 1 or l_scen_app_flag = 1) then
           return 'T';
        end if;

        l_priv_develop_scen := FPA_SECURITY_PVT.Check_User_Previlege(
                               p_privilege => FPA_SECURITY_PVT.G_DEVELOP_SCENARIO,
                               p_object_id => l_portfolio_id);

        if(l_priv_develop_scen <> 'T' ) then
           return 'T';
        end if;

        open  pc_csr (l_pc_id);
        fetch pc_csr into l_pc_status, l_portfolio_id, l_scen_count;
        close pc_csr;

        if(l_scen_ini_flag = 1 and l_scen_count > 1) then
            return 'T';
        end if;
    else
        open  pc_csr (l_pc_id);
        fetch pc_csr into l_pc_status, l_portfolio_id, l_scen_count;
        close pc_csr;
    end if;

    if(l_pc_status = 'CLOSED' or l_pc_status = 'APPROVED'
       or l_pc_status = 'SUBMITTED') then
        return 'T';
    end if;

    return 'F';

EXCEPTION
   WHEN OTHERS THEN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.String(
               FND_LOG.LEVEL_PROCEDURE,
               'fpa.sql.FPA_SCORECARD_PVT.Read_Only',
               'EXCEPTION:'||sqlerrm||p_planning_cycle_id||','||p_scenario_id);
    end if;
   return 'F';
END Read_Only;




END FPA_SCORECARDS_PVT;

/
