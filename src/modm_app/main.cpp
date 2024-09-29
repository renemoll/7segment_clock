#include <modm/board.hpp>
#include <modm/driver/display/max7219.hpp>

using Mosi = GpioOutputD7; // CN9 pin 2
using Miso = GpioInputA6;
using Sck = GpioOutputA5; // CN7 pin 10
using Spi = SpiMaster1;
using CS = GpioOutputA4; // CN7 pin 17

using Display = modm::Max7219<Spi, CS>;

int main()
{
	Board::initialize();
	Board::Leds::setOutput();

	CS::setOutput(modm::Gpio::High);

	Spi::connect<Mosi::Mosi, Miso::Miso, Sck::Sck>();
	Spi::initialize<Board::SystemClock, 1687_kHz>();

	Display::initializeMatrix();
	Display::setRegister(Display::Register::decodeMode, 0xFF);
	Display::setBrightness(1);

	Display::setRegister(Display::Register::digit0, 0x01);
	Display::setRegister(Display::Register::digit1, 0x02);
	Display::setRegister(Display::Register::digit2, 0x03);
	Display::setRegister(Display::Register::digit3, 0x04);
	Display::setRegister(Display::Register::digit4, 0x05);
	Display::setRegister(Display::Register::digit5, 0x06);
	Display::setRegister(Display::Register::digit6, 0x07);
	Display::setRegister(Display::Register::digit7, 0x08);

	while (true) {
		Board::LedGreen::toggle();
		modm::delay(500ms);

#ifdef MODM_BOARD_HAS_LOGGER
		static uint32_t counter(0);
		MODM_LOG_INFO << "Loop counter: " << (counter++) << modm::endl;
#endif
	}
	return 0;
}