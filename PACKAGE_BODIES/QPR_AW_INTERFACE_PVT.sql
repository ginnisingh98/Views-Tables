--------------------------------------------------------
--  DDL for Package Body QPR_AW_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_AW_INTERFACE_PVT" as
/* $Header: QPRAWINFCB.pls 120.0 2007/10/11 13:13:12 agbennet noship $ */
-- ATTACH_AW
procedure attach_aw
(p_aw_name IN varchar2, p_attach_mode IN varchar2, x_return_status OUT NOCOPY varchar2)
is
execution_string varchar2(100) ;
BEGIN
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.ATTACH_AW', 'Attach_aw procedure invoked' );
end if;

execution_string := 'aw attach '||p_aw_name||' '||p_attach_mode||';';
-- Attach specified AW in multi mode .
dbms_aw.execute(execution_string);

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.ATTACH_AW', 'DML Program Attach succeeded' );
end if;

x_return_status := 'success';

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.ATTACH_AW', 'Attach_aw was successful' );
end if;

EXCEPTION
when others then
x_return_status := 'error';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.ATTACH_AW', 'Attach_aw failed' );
end if;

END attach_aw;

-- DETACH_AW
procedure detach_aw
(p_aw_name IN varchar2,x_return_status OUT NOCOPY varchar2)
is
execution_string varchar2(100);
BEGIN
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.DETACH_AW', 'Detach_aw procedure invoked' );
end if;
execution_string := 'aw detach '||p_aw_name||';';
-- Detached specified AW
dbms_aw.execute(execution_string);
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.DETACH_AW', 'DML Program DETACH succeeded' );
end if;
x_return_status := 'success';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.DETACH_AW', 'Detach_aw program succeeded' );
end if;
EXCEPTION
when others then
x_return_status := 'error';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.DETACH_AW', 'Detach_aw program failed' );
end if;
END detach_aw;
-- writeback_aw
/*
procedure writeback_aw
(dimTable in QPR_DIM_TABLE,measTable in QPR_MEAS_TABLE,x_return_status OUT NOCOPY varchar2)
is
dimString varchar2(1000);
measString varchar2(1000);
dimCounter int := 1;
measCounter int := 1;
cell_id int := 1;
dimCheck boolean := false;
modMeasVal varchar2(100);
begin
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.WRITEBACK_AW', 'writeback_aw procedure invoked' );
end if;
      << outer_loop >>
      while (1=1)
      loop
        << dim_loop >>
        while (dimTable(dimCounter).cell_id = cell_id)
        loop
        dimString := dimString || 'limit '||dimTable(dimCounter).dimName ||' to'''||dimTable(dimCounter).dimValue||''';' ;
        dimCounter := dimCounter +1;
        dimCheck := true;
        if(dimCounter > dimTable.count) then
          exit dim_loop;
        end if;
      end loop dim_loop;
      << meas_loop >>
      while(measTable(measCounter).cell_id = cell_id)
      loop
        modMeasVal := 'NA';
	if(measTable(measCounter).measValue =  oracleNull)THEN
	   measString := measString || measTable(measCounter).measName ||' = '|| modMeasVal || ';' ;
        elsif  measTable(measCounter).measDataType = 'Text'  THEN
            measString := measString || measTable(measCounter).measName ||' = '''|| measTable(measCounter).measValue || ''';' ;

	    elsif measTable(measCounter).measDataType = 'Number' THEN
        measString := measString || measTable(measCounter).measName ||' = '|| measTable(measCounter).measValue || ';' ;
    end if;
        measCounter := measCounter+1;
      if(dimCheck <> false) then -- Check if dimension isn't null in which caseentire cube wud b set to above value.
        dbms_aw.execute(dimString || measString);
      end if;
      if(measCounter > measTable.count) then
          exit outer_loop;
       end if;
       measString := '';
       end loop meas_loop;
       cell_id :=cell_id+1;
       dimString := '';
       dimCheck := false;
       end loop outer_loop;
      dbms_aw.execute('ALLSTAT;');
   x_return_status := 'success';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.WRITEBACK_AW', 'WRITEBACK_AW procedure succeeded' );
end if;
  EXCEPTION
when others then
x_return_status := 'error';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.WRITEBACK_AW', 'WRITEBACK_AW procedure failed '||sqlcode||' '||sqlerrm);
end if;

end writeback_aw;
*/
/*
--Model Execution
procedure executeModel(modelName in varchar2, modelDimension in varchar2, modelMeasName in varchar2, modelExecScope in QPR_DIM_TABLE, writeBackMeas in QPR_MEAS_MET_TABLE,x_return_status OUT NOCOPY varchar2)
AS
cmdString varchar2(4000);
dimName varchar2(4000);
BEGIN
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.EXECUTEMODEL', 'EXECUTEMODEL procedure invoked' );
end if;

    dimName := '';

    for i in 1..modelExecScope.count loop
       if dimName = modelExecScope(i).dimName then
	  cmdString := cmdString || 'limit '||modelExecScope(i).dimName ||' add '''||modelExecScope(i).dimValue||''';';
       else
	  cmdString := cmdString || 'limit '||modelExecScope(i).dimName ||' to '''||modelExecScope(i).dimValue||''';';
	  dimName := modelExecScope(i).dimName;
       end if;
    end loop;
    dbms_aw.execute(cmdString);

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.EXECUTEMODEL', 'Scope set for the execution of the model' );
end if;



    cmdString := '';
    cmdString := modelMeasName || '= 0.0;';
    dbms_aw.execute(cmdString);


    dbms_aw.execute('naskip2 = yes');
    dbms_aw.execute(modelName ||' '||modelMeasName);
    dbms_aw.execute('naskip2 = no');

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.EXECUTEMODEL', 'Model '||modelName ||' Executed successfully ');
end if;



    cmdString := '';
    for i in 1..writeBackMeas.count loop
    cmdString := cmdString || 'limit '||modelDimension ||' to '||''''||writeBackMeas(i).measPPACode||''''||' ;';
    cmdString := cmdString ||writeBackMeas(i).measId ||' = ' ||modelMeasName||' ; ';
    end loop;
    dbms_aw.execute(cmdString);
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.EXECUTEMODEL', 'Measure Values written back after the execution of model');
end if;

    cmdString := 'ALLSTAT;';
    dbms_aw.execute(cmdString);
    x_return_status := 'success';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.EXECUTEMODEL', 'ExecuteModel Procedure successful');
end if;

EXCEPTION
    when others then
    x_return_status := 'error';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.EXECUTEMODEL', 'ExecuteModel Procedure failed '||sqlcode||' '||sqlerrm);
end if;
END;

--Commit
procedure commitData(commitMeas in QPR_MEAS_MET_TABLE,x_return_status OUT NOCOPY varchar2)
AS
LOCK_ACQUIRE_FAILED1 EXCEPTION;
LOCK_ACQUIRE_FAILED2 EXCEPTION;
LOCK_ACQUIRE_FAILED3 EXCEPTION;

PRAGMA EXCEPTION_INIT(LOCK_ACQUIRE_FAILED1, -37040);
PRAGMA EXCEPTION_INIT(LOCK_ACQUIRE_FAILED2, -37044);
PRAGMA EXCEPTION_INIT(LOCK_ACQUIRE_FAILED3, -37011);
cmdString varchar2(4000);
measString varchar2(4000);
BEGIN
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'Procedure CommitData Invoked');
end if;


    cmdString := '';
    measString := '';
    for i in 1..commitMeas.count loop
    if ( i = 1 ) then
    	measString := commitMeas(i).measId;
    else
        measString := measString||','|| commitMeas(i).measid;
    end if;
    end loop;
    cmdString := 'acquire '||measString||';';
    dbms_aw.execute(cmdString);
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'Acquired the lock for the measures that are to be committed');
end if;



    cmdString := 'UPDATE;';
    dbms_aw.execute(cmdString);

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'Update of measures Successful');
end if;


    cmdString := 'COMMIT;';
    dbms_aw.execute(cmdString);

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'Commit measure values Successful');
end if;


    cmdString := 'Release '|| measString ||';';
    dbms_aw.execute(cmdString);

if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'Released the lock acquired on the measures');
end if;
x_return_status := 'success';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'CommitData Procedure Successful');
end if;
EXCEPTION
    WHEN LOCK_ACQUIRE_FAILED1 THEN
    x_return_status := 'LOCK_ACQUIRE_FAILED';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'CommitData Procedure failed '||x_return_status||sqlcode||' '||sqlerrm);
end if;

 WHEN LOCK_ACQUIRE_FAILED2 THEN
    x_return_status := 'LOCK_ACQUIRE_FAILED';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'CommitData Procedure failed '||x_return_status||sqlcode||' '||sqlerrm);
end if;

 WHEN LOCK_ACQUIRE_FAILED3 THEN
    x_return_status := 'LOCK_ACQUIRE_FAILED';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'CommitData Procedure failed '||x_return_status||sqlcode||' '||sqlerrm);
end if;

 when others then
    x_return_status := 'error';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.COMMITDATA', 'CommitData Procedure failed '||x_return_status||sqlcode||' '||sqlerrm);
end if;

END;

procedure handleMeas(commitMeas in QPR_MEAS_MET_TABLE,dim in QPR_MEAS_MET_TABLE,acquire in varchar2,x_return_status OUT NOCOPY varchar2)
as
LOCK_ACQUIRE_FAILED1 EXCEPTION;
LOCK_ACQUIRE_FAILED2 EXCEPTION;
PRAGMA EXCEPTION_INIT(LOCK_ACQUIRE_FAILED1, -37040);
PRAGMA EXCEPTION_INIT(LOCK_ACQUIRE_FAILED2, -37011);
dimString varchar2(4000);
begin
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.handleMeas','Enter '||acquire);
end if;

   for i in 1..dim.count loop
   if(i = 1) then
      dimString := dim(i).measid;
   else
   dimString := dimString||','||dim(i).measid;
   end if;

end loop;


    if (acquire = 'YES') then
    for i in 1..commitMeas.count loop
       dbms_aw.execute('acquire resync '||commitMeas(i).measid||' consistent with '||dimString);
    end loop;
    else
       dbms_aw.execute('update');
       dbms_aw.execute('commit');
    for i in 1..commitMeas.count loop
       dbms_aw.execute('release '||commitMeas(i).measid);
    end loop;
       end if;

x_return_status := 'success';

EXCEPTION
    WHEN LOCK_ACQUIRE_FAILED1 THEN
    x_return_status := 'LOCK_ACQUIRE_FAILED';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.handleMeas', x_return_status||' '||sqlcode||' '||sqlerrm);
end if;

 WHEN LOCK_ACQUIRE_FAILED2 THEN
    x_return_status := 'LOCK_ACQUIRE_FAILED';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.handleMeas', x_return_status||' '||sqlcode||' '||sqlerrm);
end if;

 when others then
    x_return_status := 'error';
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'QPR_AW_INTERFACE_PVT.handleMeas', x_return_status||' '||sqlcode||' '||sqlerrm);
end if;
end;*/

END QPR_AW_INTERFACE_PVT;

/
