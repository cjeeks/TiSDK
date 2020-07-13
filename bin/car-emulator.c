#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

#include <linux/can.h>
#include <linux/can/raw.h>

#include <math.h>

int main(int argc, char **argv)
{
	int s; /* can raw socket */ 
	struct sockaddr_can addr;
	struct can_frame frame;
	struct ifreq ifr;
	uint32_t i = 0;
	uint32_t value, speed_value, rpm_value;

	if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
		perror("socket");
		return 1;
	}

	strncpy(ifr.ifr_name, "can0", IFNAMSIZ - 1);
	ifr.ifr_name[IFNAMSIZ - 1] = '\0';
	ifr.ifr_ifindex = if_nametoindex(ifr.ifr_name);
	if (!ifr.ifr_ifindex) {
		perror("if_nametoindex");
		return 1;
	}

	memset(&addr, 0, sizeof(addr));
	addr.can_family = AF_CAN;
	addr.can_ifindex = ifr.ifr_ifindex;

	if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("bind");
		return 1;
	}


	while(true) {
		speed_value = (uint32_t)((0.5 * sinf(0.01 * i) + 0.5) * 240);
		rpm_value = (uint32_t)((0.5 * sinf(0.01 * i) + 0.5) * 8000);
		value = 1 << ((i / 40) % 22);
		i++;

		memset(&frame, 0, sizeof(frame));
		frame.can_id = 0x1f0; /* I use this ID */
		frame.can_dlc = 8;
		if(i % 40 == 0) {
			frame.data[0] = 0x07;
			frame.data[1] = (uint8_t)((value & 0xff0000) >> 16);
			frame.data[2] = (uint8_t)((value & 0xff00) >> 8);
			frame.data[3] = (uint8_t)(value & 0xff);
		} else {
			frame.data[0] = 0x06;
		}
		frame.data[4] = (uint8_t)((speed_value & 0xff00) >> 8);
		frame.data[5] = (uint8_t)(speed_value & 0xff);
		frame.data[6] = (uint8_t)((rpm_value & 0xff00) >> 8);
		frame.data[7] = (uint8_t)(rpm_value & 0xff);
	
		if (write(s, &frame, sizeof(frame)) != sizeof(frame)) {
			perror("write");
			return 1;
		}
		usleep(10000);
	}

	close(s);

	return 0;


}
