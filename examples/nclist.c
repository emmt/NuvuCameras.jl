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

#define CALL(func,args) do {                    \
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
  NcCam cam;
  NcCtrlList ctrl;
  int basic = 1;
  int nbufs = 4;
  int nmodes;
  int i, j;
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
    CALL(ncControllerListOpenBasic,(&ctrl));
  } else {
    CALL(ncControllerListOpen,(&ctrl));
  }

  CALL(ncControllerListGetSize,(ctrl, &numcontrollers));
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

    CALL(ncControllerListGetPortUnit,(ctrl, i, &portunit));
    printf("  %d: Port unit --------> %d\n", i, portunit);

    CALL(ncControllerListGetPortChannel,(ctrl, i, &portchannel));
    printf("  %d: Port channel -----> %d\n", i, portchannel);

    uniqueid = GETSTR(ncControllerListGetUniqueID, ctrl, i);
    printf("  %d: Unique ID --------> %s\n", i, uniqueid);
    free(uniqueid);

    detectortype = GETSTR(ncControllerListGetDetectorType, ctrl, i);
    printf("  %d: Detector type ----> %s\n", i, detectortype);
    free(detectortype);

    CALL(ncControllerListGetFullSizeSize,(ctrl, i, &fullwidth, &fullheight));
    printf("  %d: Full size --------> %d x %d\n", i, fullwidth, fullheight);

    CALL(ncControllerListGetDetectorSize,(ctrl, i, &detectorwidth, &detectorheight));
    printf("  %d: Detector size ----> %d x %d\n", i, detectorwidth, detectorheight);
  }
  printf("\n");

  CALL(ncControllerListGetFreePortCount,(ctrl, &numfreeports));
  printf("%d free port(s) found\n", numfreeports);
  for (i = 0; i < numfreeports; ++i) {
    portinterface = GETSTR(ncControllerListGetFreePortInterface, ctrl, i);
    printf("  %d: Port interface ---> %s\n", i, portinterface);
    free(portinterface);

    CALL(ncControllerListGetFreePortUnit,(ctrl, i, &portunit));
    printf("  %d: Port unit --------> %d\n", i, portunit);

    CALL(ncControllerListGetFreePortChannel,(ctrl, i, &portchannel));
    printf("  %d: Port channel -----> %d\n", i, portchannel);

    uniqueid = GETSTR(ncControllerListGetFreePortUniqueID, ctrl, i);
    printf("  %d: Unique ID --------> %s\n", i, uniqueid);
    free(uniqueid);
  }
  printf("\n");

  CALL(ncControllerListGetPluginCount,(ctrl, &numplugins));
  printf("%d plugin(s) found\n", numplugins);
  for (i = 0; i < numplugins; ++i) {
    pluginname = GETSTR(ncControllerListGetPluginName, ctrl, i);
    printf("  %d: Plugin name ------> %s\n", i, pluginname);
    free(pluginname);
  }


  for (i = 0; i < numcontrollers; ++i) {
    CALL(ncCamOpenFromList,(ctrl, i, nbufs, &cam));
    CALL(ncCamGetNbrReadoutModes,(cam, &nmodes));
    for (j = 1; j <= nmodes; ++j) {
      enum Ampli amplitype;
      char ampliname[8];
      int vfreq, hfreq;
      CALL(ncCamGetReadoutMode,(cam, j, &amplitype, ampliname, &vfreq, &hfreq));
      printf(" > Readout mode number %d:\n", j);
      printf("   Amplifier type: %s (%s)\n", ampliname,
             (amplitype == NOTHING ? "NOTHING" : (
               amplitype == EM ? "EM" : (
                 amplitype == CONV ? "CONV" : "???"))));
      printf("   Vertical frequency:   %10.6f MHz\n", 1e-6*vfreq);
      printf("   Horizontal frequency: %10.6f MHz\n", 1e-6*hfreq);
    }
  }

  if (ctrl != NULL) {
    CALL(ncControllerListFree,(ctrl));
  }

  return 0;
}
