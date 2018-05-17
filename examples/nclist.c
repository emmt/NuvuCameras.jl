/*
 * nclist.c -
 *
 * List Nüvü Camēras controllers.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "nc_driver.h"

const char* progname = "listctrl";

#define TRY(func,args) do {                     \
    int status = func args;                     \
    if (status != NC_SUCCESS) {                 \
      failure(#func, status);                   \
    }                                           \
  } while (0)

static void failure(const char* func, int status)
{
  fprintf(stderr, "%s: function `%s` failed with code %d\n",
          progname, func, status);
  exit(1);
}

static char* getctrlstring(const char* funcname,
                           int (*func)(const NcCtrlList ctrl,
                                       int index, char* buf, int size),
                           const NcCtrlList ctrl,
                           int index)
{
  int status, size;
  char* str;

  /* Get the string size (including the string terminator). */
  size = func(ctrl, index, NULL, 0);
  if (size <= 0) {
    /* Assume out of range index. */
    failure(funcname, NC_ERROR_GRAB_PARAM_OUT);
  }

  /* Allocate the string, fill it and return it. */
  str = (char*)malloc(size);
  if (str == NULL) {
    fprintf(stderr, "%s: cannot allocate %d bytes\n", progname, size);
    exit(1);
  }
  status = func(ctrl, index, str, size);
  if (status != NC_SUCCESS) {
    failure(funcname, status);
  }
  return str;
}

#define GETSTR(func, ctrl, index) getctrlstring(#func, func, ctrl, index)

int main(int argc, char* argv[])
{
  NcCtrlList ctrl;
  int basic = 1;
  int i;
  int numcontrollers, numfreeports, numplugins;
  int portunit, portchannel;
  int fullwidth, fullheight;
  int detectorwidth, detectorheight;
  char* serial;
  char* model;
  char* portinterface;
  char* uniqueid;
  char* detectortype;
  char* pluginname;

  ctrl = NULL;
  if (basic) {
    TRY(ncControllerListOpenBasic,(&ctrl));
  } else {
    TRY(ncControllerListOpen,(&ctrl));
  }

  TRY(ncControllerListGetSize,(ctrl, &numcontrollers));
  printf("%d controller(s) found\n", numcontrollers);
  for (i = 0; i < numcontrollers; ++i) {
    model = GETSTR(ncControllerListGetModel, ctrl, i);
    printf("  %d: Model ------------> %s\n", i, model);
    free(model);

    serial = GETSTR(ncControllerListGetSerial, ctrl, i);
    printf("  %d: Serial -----------> %s\n", i, serial);
    free(serial);

    portinterface = GETSTR(ncControllerListGetPortInterface, ctrl, i);
    printf("  %d: Port interface ---> %s\n", i, portinterface);
    free(portinterface);

    TRY(ncControllerListGetPortUnit,(ctrl, i, &portunit));
    printf("  %d: Port unit --------> %d\n", i, portunit);

    TRY(ncControllerListGetPortChannel,(ctrl, i, &portchannel));
    printf("  %d: Port channel -----> %d\n", i, portchannel);

    uniqueid = GETSTR(ncControllerListGetUniqueID, ctrl, i);
    printf("  %d: Unique ID --------> %s\n", i, uniqueid);
    free(uniqueid);

    detectortype = GETSTR(ncControllerListGetDetectorType, ctrl, i);
    printf("  %d: Detector type ----> %s\n", i, detectortype);
    free(detectortype);

    TRY(ncControllerListGetFullSizeSize,(ctrl, i, &fullwidth, &fullheight));
    printf("  %d: Full size --------> %d x %d\n", i, fullwidth, fullheight);

    TRY(ncControllerListGetDetectorSize,(ctrl, i, &detectorwidth, &detectorheight));
    printf("  %d: Detector size ----> %d x %d\n", i, detectorwidth, detectorheight);
  }
  printf("\n");

  TRY(ncControllerListGetFreePortCount,(ctrl, &numfreeports));
  printf("%d free port(s) found\n", numfreeports);
  for (i = 0; i < numfreeports; ++i) {
    portinterface = GETSTR(ncControllerListGetFreePortInterface, ctrl, i);
    printf("  %d: Port interface ---> %s\n", i, portinterface);
    free(portinterface);

    TRY(ncControllerListGetFreePortUnit,(ctrl, i, &portunit));
    printf("  %d: Port unit --------> %d\n", i, portunit);

    TRY(ncControllerListGetFreePortChannel,(ctrl, i, &portchannel));
    printf("  %d: Port channel -----> %d\n", i, portchannel);

    uniqueid = GETSTR(ncControllerListGetFreePortUniqueID, ctrl, i);
    printf("  %d: Unique ID --------> %s\n", i, uniqueid);
    free(uniqueid);
  }
  printf("\n");

  TRY(ncControllerListGetPluginCount,(ctrl, &numplugins));
  printf("%d plugin(s) found\n", numplugins);
  for (i = 0; i < numplugins; ++i) {
    pluginname = GETSTR(ncControllerListGetPluginName, ctrl, i);
    printf("  %d: Plugin name ------> %s\n", i, pluginname);
    free(pluginname);
  }

  if (ctrl != NULL) {
    TRY(ncControllerListFree,(ctrl));
  }

  return 0;
}
