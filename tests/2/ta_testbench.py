import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.clock import Clock
import random

# Helper function to reset the DUT
async def reset_dut(dut, duration_ns=100):
    dut.rst.value = 1
    dut.enable.value = 0
    dut.training_sel.value = 0
    await Timer(duration_ns, units='ns')
    dut.rst.value = 0
    await Timer(duration_ns, units='ns')

@cocotb.test()
async def ta_basic_test(dut):
    """ Basic test to check inference and training behavior of the Tsetlin Automaton (TA) """
    
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    cocotb.start_soon(Clock(dut.rand_clk, 15, units="ns").start())
    
    dut.rand_out.value = 1

    # Reset the DUT
    await reset_dut(dut)

    # Test case 1: Simple inference with literal_in = 1, internal_weight initialized to 0
    dut.enable.value = 1
    dut.literal_in.value = 1
    dut.training_sel.value = 0  # Inference mode

    await RisingEdge(dut.clk)
    
    assert dut.ta_result.value == 0, f"Test failed on inference: Expected ta_result=1, but got ta_result={dut.ta_result.value}"

    # Test case 2: Training mode with feedback - Reward scenario
    dut.training_sel.value = 1  # Training mode
    dut.type_feedback.value = 0  # Type I feedback
    dut.clause_result.value = 1  # Clause result is positive

    await RisingEdge(dut.clk)
    
    # Transition to TRAIN and then to FEEDBACK
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    assert dut.internal_weight.value == 1, f"Test failed on training: Expected internal_weight=1, but got internal_weight={dut.internal_weight.value}"

    # Test case 3: Training mode with feedback - Penalization scenario
    dut.literal_in.value = 0
    dut.type_feedback.value = 1  # Type II feedback
    dut.clause_result.value = 0  # Clause result is negative

    await RisingEdge(dut.clk)

    # Transition to TRAIN and then to FEEDBACK
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    assert dut.internal_weight.value == 0, f"Test failed on training: Expected internal_weight=0, but got internal_weight={dut.internal_weight.value}"

    dut._log.info("Test completed successfully")

@cocotb.test()
async def ta_randomized_test(dut):
    """ Test with randomized inputs to cover different scenarios """
    
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    cocotb.start_soon(Clock(dut.rand_clk, 15, units="ns").start())

    # Reset the DUT
    await reset_dut(dut)
    
    enable = 1
    # Running a randomized test sequence
    for _ in range(50):
        
        training_sel = random.randint(0, 1)
        literal_in = random.randint(0, 1)
        type_feedback = random.randint(0, 1)
        clause_result = random.randint(0, 1)

        dut.enable.value = enable
        dut.training_sel.value = training_sel
        dut.literal_in.value = literal_in
        dut.type_feedback.value = type_feedback
        dut.clause_result.value = clause_result

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)  # Ensure the system has processed

        dut._log.info(f"enable={enable}, training_sel={training_sel}, literal_in={literal_in}, "
                      f"type_feedback={type_feedback}, clause_result={clause_result}, "
                      f"ta_result={dut.ta_result.value}, internal_weight={dut.internal_weight.value}")

